# app/controllers/trainings_controller.rb
class TrainingsController < ApplicationController
  before_action :check_user_id, only: [:latest_trainings, :initial_trainings, :all_trainings]

  # GET /latest-trainings
  def latest_trainings
    user_id = params[:user_id]
    return render json: { success: false, error: 'UserId is missing' }, status: :bad_request if user_id.blank?
    result = find_training(user_id, :desc)
    if result[:training] || result[:weight_training]
      render json: {
        success: true,
        date: result[:training]&.date,
        weight: result[:weight_training]&.weight
      }
    else
      render json: { success: false, error: "No training data found" }
    end
  end

  # GET /initial-trainings
  def initial_trainings
    user_id = params[:user_id]
    return render json: { success: false, error: 'UserId is missing' }, status: :bad_request if user_id.blank?
    result = find_training(user_id, :asc)
    if result[:training] || result[:weight_training]
      render json: {
        success: true,
        date: result[:training]&.date,
        weight: result[:weight_training]&.weight
      }
    else
      render json: { success: false, error: "No training data found" }
    end
  end

  # POST /trainings
  def create
    training = Training.new(training_params)
    if training.save
      render json: { success: true, inserted_id: training.id }, status: :created
    else
      render json: { success: false, errors: training.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /all-trainings
  def all_trainings
    user_id = params[:user_id]
    puts "Received user_id: #{user_id}"
    return render json: { success: false, error: 'UserId is missing' }, status: :bad_request if user_id.blank?
    trainings = Training.where(user_id: user_id).order(:date => :asc)
    puts "Retrieved trainings: #{trainings.inspect}"
    if trainings.empty?
      puts "No training data found"
      render json: { success: false, message: "No data found" }
    else
      last_known_weight = nil
      processed_trainings = trainings.map do |training|
        last_known_weight = training.weight if training.weight.present?
        { date: training.date, weight: last_known_weight }
      end
      puts "Processed trainings: #{processed_trainings.inspect}"
      render json: { success: true, trainings: processed_trainings }
    end
  end

  # Method to compare first login and count training sessions since then
  def training_stats
    user_id = params[:user_id]
    return render json: { success: false, error: 'UserId is missing' }, status: :bad_request if user_id.blank?
    # Fetch the first login date from user_data
    first_login = UserData.where(user_id: user_id).order_by(:created_at.asc).first
    return render json: { success: false, error: 'No user data found' }, status: :not_found if first_login.nil?
    first_login_date = first_login.created_at.to_date
    # Count the number of training sessions since the first login date
    training_count = Training.where(user_id: user_id, :date.gte => first_login_date).count
    # Calculate the total number of days since the user joined
    total_days_since_joining = (Date.today - first_login_date).to_i
    # Return the result
    render json: {
      success: true,
      training_count: training_count,
      total_days_since_joining: total_days_since_joining,
      first_login_date: first_login_date
    }
  end

  # GET /training-repository
  def training_repository
    trainings = TrainingRepository.all
    if trainings.empty?
      render json: { success: false, message: "No training repository data found" }
    else
      render json: { success: true, trainings: trainings }
    end
  end

  # POST /training-repository (to add new training to repository)
  def create_training_repository
    training = TrainingRepository.new(training_repository_params)
    if training.save
      render json: { success: true, training: training }, status: :created
    else
      render json: { success: false, errors: training.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def check_user_id
    if params[:user_id].blank?
      render json: { success: false, error: 'UserId is missing' }, status: :bad_request
    end
  end
  # Helper method to fetch the latest and initial trainings
  def find_training(user_id, order)
    {
      training: Training.where(user_id: user_id).order(date: order).first,
      weight_training: Training.where(user_id: user_id, :weight.nin => [nil]).order(date: order).first
    }
  end

  def training_params
    params.require(:training).permit(:user_id, :date, :training, :weight)
  end

  def training_repository_params
    params.require(:training).permit(:training_name, :type, :duration, :calories, :description)
  end
end
