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

  def new
    @plant = Plant.new
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

  def edit
    @plant = Plant.find(params[:id])
  end

  def update
    @plant = Plant.find(params[:id])
    if @plant.update(plant_params)
      respond_to do |format|
        format.html { redirect_to plant_path(@plant), notice: "Planta atualizada com sucesso!" }
        format.json { render json: @plant }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @plant = Plant.find(params[:id])
    @plant.destroy
    respond_to do |format|
      format.html { redirect_to plants_path, notice: "Planta removida com sucesso!" }
      format.json { head :no_content }
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:name, :species, :nickname, :image)
  end
end
