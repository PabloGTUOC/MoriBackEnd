require_dependency 'life_methods'
class UserDataController < ApplicationController

  # GET /user_data
  def user_data
    user_id = params[:user_id]
    puts "Received user_id: #{user_id}"
    user_data = UserData.where(user_id: user_id).order_by(created_at: :desc).first
    puts "Retrieved data: #{user_data.inspect}"

    if user_data
      # Step 1: Get base life expectancy
      base_life_expectancy = LifeMethodsService.fetch_base_life_expectancy(user_data)

      # Step 2: Get latest weight or fallback to the initial weight
      latest_weight = LifeMethodsService.fetch_latest_weight(user_data.user_id)
      puts "Latest Weight: #{latest_weight}"

      # Step 3: Adjust life expectancy based on user data
      adjusted_life_expectancy = LifeMethodsService.adjust_life_expectancy(base_life_expectancy, user_data, latest_weight)

      # Step 4: Return the user data along with the adjusted life expectancy and the base life expectancy
      render json: {
        success: true,
        user_data: user_data,
        base_life_expectancy: base_life_expectancy, # Include base life expectancy in response
        adjusted_life_expectancy: adjusted_life_expectancy
      }
    else
      puts "No user data found"
      render json: { success: false, message: "No data found" }
    end
  end

  # POST /user_data
  def create
    user_data = UserData.new(user_data_params)
    if user_data.save
      render json: { success: true, inserted_id: user_data.id }, status: :created
    else
      Rails.logger.error("User data save failed: #{user_data.errors.full_messages}")
      render json: { success: false, errors: user_data.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Strong parameters for user data
  def user_data_params
    params.require(:user_data).permit(:user_id, :dob, :gender, :height, :weight, :trainingFrequency, :smoker, :drinker, :country_code).tap do |whitelisted|
      whitelisted[:trainingFrequency] = params[:user_data][:trainingFrequency] if params[:user_data][:trainingFrequency]
    end
  end
end
