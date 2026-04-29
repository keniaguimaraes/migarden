class PlantsController < ApplicationController
  def index
    @plants = Plant.all
    render json: @plants
  end

  def show
    @plant = Plant.find(params[:id])
    render json: @plant.as_json(include: :care_parameters)
  end

  def create
    @plant = Plant.new(plant_params)

    if @plant.save
      render json: @plant, status: :created
    else
      render json: @plant.errors, status: :unprocessable_entity
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:name, :image)
  end
end
