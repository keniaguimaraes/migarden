class PlantsController < ApplicationController
  def index
    @plants = Plant.all
    respond_to do |format|
      format.html # Renderiza a view HTML
      format.json { render json: @plants }
    end
  end

  def show
    @plant = Plant.find(params[:id])
    @care_parameters = @plant.care_parameters
    respond_to do |format|
      format.html # Renderiza a view HTML
      format.json { render json: @plant, include: :care_parameters }
    end
  end

  def create
    @plant = Plant.new(plant_params)
    if @plant.save
      respond_to do |format|
        format.html { redirect_to plants_path, notice: "Planta criada com sucesso!" }
        format.json { render json: @plant, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:name, :species, :nickname, :image)
  end
end
