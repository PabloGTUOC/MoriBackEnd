# app/controllers/weight_updates_controller.rb
class WeightUpdatesController < ApplicationController
  before_action :check_user_id, only: [:create]

  # POST /weight_updates
  def create
    weight_update = WeightUpdate.new(weight_update_params)
    if weight_update.save
      render json: { success: true, inserted_id: weight_update.id }, status: :created
    else
      Rails.logger.error("Failed to save WeightUpdate: #{weight_update.errors.full_messages}")
      render json: { success: false, errors: weight_update.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /latest_weight
  def latest_weight
    user_id = params[:user_id]
    latest_weight = WeightUpdate.where(user_id: user_id)
                                .order_by(:date.desc, _id: :desc)
                                .first
    if latest_weight
      render json: { success: true, weight: latest_weight.weight, date: latest_weight.date }
    else
      render json: { success: false, error: "No weight data found" }
    end
  end

  private

  def check_user_id
    if params[:weight_update].blank? || params[:weight_update][:user_id].blank?
      render json: { success: false, error: 'UserId is missing' }, status: :bad_request
    end
  end

  def weight_update_params
    params.require(:weight_update).permit(:user_id, :date, :weight)
  end
end
