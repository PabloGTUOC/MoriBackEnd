# app/controllers/moods_controller.rb
require 'net/http'
require 'json'
require_dependency 'life_methods'

class MoodsController < ApplicationController
  def save_mood
    # Access the data from mood_data
    mood_data = params[:mood_data]
    user_id = mood_data[:user_id]
    mood = mood_data[:mood]
    date = mood_data[:date]
    # Check if any of the parameters are missing
    if user_id.blank? || mood.blank? || date.blank?
      return render json: { success: false, message: "Missing parameters" }, status: :bad_request
    end
    # Create a new mood entry
    new_mood = Mood.new(
      user_id: user_id,
      mood: mood,
      date: date
    )
    if new_mood.save
      render json: { success: true, message: "Mood saved successfully" }, status: :ok
    else
      render json: { success: false, message: new_mood.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def generate_recommendation
    mood_data = params[:mood_data]
    user_id = mood_data[:user_id]
    mood = mood_data[:mood]
    date = mood_data[:date]

    # Fetch user data from UserData model
    user_data = UserData.where(user_id: user_id).order_by(created_at: :desc).first
    if user_data.nil?
      return render json: { success: false, message: "User data not found" }, status: :bad_request
    end

    # Fetch adjusted life expectancy from UserDataController
    base_life_expectancy = LifeMethodsService.fetch_base_life_expectancy(user_data)
    latest_weight = LifeMethodsService.fetch_latest_weight(user_data.user_id)
    adjusted_life_expectancy = LifeMethodsService.adjust_life_expectancy(base_life_expectancy, user_data, latest_weight)

    # Calculate the number of weeks left to live based on adjusted life expectancy
    age = LifeMethodsService.calculate_age(user_data.dob)
    weeks_left_to_live = (adjusted_life_expectancy - age) * 52 # Convert to weeks

    gender = user_data.gender
    location = user_data.country_code # Assuming location is stored as country code

    # Check all required parameters are present
    if mood.blank? || location.blank? || gender.blank? || age.blank? || weeks_left_to_live.blank?
      return render json: { success: false, message: "Missing parameters" }, status: :bad_request
    end

    # Prepare the prompt for ChatGPT
    prompt = "The user is feeling #{mood} today. They are #{age} years old, living in #{location}, and identify as #{gender}. "\
      "They have approximately #{weeks_left_to_live} weeks left to live. "\
      "Provide a personalized recommendation to help the user make the most of their day based on their mood, and whenever possible, "\
      "include concrete exercises, like breathing exercises for anxiety, on a maximum of 200 words altogether"


    # Call ChatGPT API
    gpt_response = query_chatgpt(prompt)

      if gpt_response
        render json: { success: true, recommendation: gpt_response }, status: :ok
      else
        render json: { success: false, message: "Failed to get recommendation" }, status: :unprocessable_entity
      end
  end

  private

  def query_chatgpt(prompt)
    api_key = ENV["CHATGPT_API_KEY"]
    uri = URI.parse("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    })

    request.body = {
      model: 'gpt-4o-mini',
      messages: [
        { role: "system", content: "You are a coach with focus on mental health and training for healthy individuals." },
        { role: "user", content: prompt }
      ],
      max_tokens: 300,
      temperature: 0.7
    }.to_json

    response = http.request(request)

    if response.code == "200"
      json_response = JSON.parse(response.body)
      Rails.logger.info("GPT Response: #{json_response}")
      json_response['choices'][0]['message']['content'].strip
    else
      Rails.logger.error("Failed to query chatgpt: #{response.body}")
      nil
    end
  end
end

