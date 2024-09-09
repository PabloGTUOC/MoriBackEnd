# app/services/life_methods_service.rb
class LifeMethodsService
  def self.adjust_life_expectancy(base_life_expectancy, user_data, latest_weight = nil)
    adjusted_life_expectancy = base_life_expectancy
    weight_to_use = latest_weight || user_data.weight

    # Adjust for smoking
    adjusted_life_expectancy -= 10 if user_data.smoker

    # Adjust for drinking
    adjusted_life_expectancy -= 4 if user_data.drinker

    # Calculate BMI and adjust
    bmi = calculate_bmi(weight_to_use, user_data.height)
    case bmi
    when 19..24.99
      # No adjustment for healthy BMI
    when 25..27.49
      adjusted_life_expectancy -= 1.5
    when 27.5..29.99
      adjusted_life_expectancy -= 3
    when 30..34.99
      adjusted_life_expectancy -= 6
    when 35..39.99
      adjusted_life_expectancy -= 6
    when 40..Float::INFINITY
      adjusted_life_expectancy -= 10
    else
      # For BMI less than 19
      adjusted_life_expectancy -= 2
    end

    # Adjust for training frequency
    case user_data.trainingFrequency
    when 0
      adjusted_life_expectancy -= 4
    when 1..2
      adjusted_life_expectancy += 4
    when 3..4
      adjusted_life_expectancy += 6
    when 5..6
      adjusted_life_expectancy += 8
    when 7
      adjusted_life_expectancy += 10
    end

    adjusted_life_expectancy
  end

  def self.fetch_base_life_expectancy(user_data)
    country_code = user_data.country_code.strip # Use country code from user_data
    gender = user_data.gender.strip.capitalize # Capitalize the first letter to match the data in MongoDB
    type = "LifeExpectancy_Gen"

    # Debugging: Print the query parameters
    puts "Querying life expectancy with:"
    puts "Country Code: #{country_code}"
    puts "Gender: #{gender}"
    puts "Type: #{type}"

    collection = Mongoid.default_client[:life_expectancy]

    life_expectancy_record = collection.find(
      "Country_Code": country_code,
      "Gender": gender,
      'Type': type,
      ).first

    if life_expectancy_record
      puts "Life Expectancy Record Found: #{life_expectancy_record}"
      life_expectancy_record["Years"]
    else
      puts "No matching life expectancy record found."
      0
    end
  end

  def self.fetch_latest_weight(user_id)
    latest_weight_record = WeightUpdate.where(user_id: user_id).order_by(date: :desc, _id: :desc).first
    latest_weight_record ? latest_weight_record.weight : nil
  end

  def self.calculate_bmi(weight, height)
    height_in_meters = height / 100.0
    weight / (height_in_meters * height_in_meters)
  end

  def self.calculate_age(dob)
    today = Date.today
    age = today.year - dob.year
    age -= 1 if today < dob + age.years # Subtract 1 if the user's birthday hasn't occurred yet this year
    age
  end
end