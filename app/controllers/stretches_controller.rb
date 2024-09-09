class StretchesController < ApplicationController
  def index
    stretches = StretchRepository.all
    render json: { success: true, stretches: stretches }
  end

  def create
    stretch = StretchRepository.new(stretch_params)
    if stretch.save
      render json: { success: true, stretch: stretch }
    else
      render json: { success: false, errors: stretch.errors.full_messages }
    end
  end

  private

  def stretch_params
    params.require(:stretch).permit(:stretch_name, :description, :video_link)
  end
end