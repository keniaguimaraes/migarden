class CareParametersController < ApplicationController
  def new
    @plant = Plant.find(params[:plant_id])
    @care_parameter = CareParameter.new
  end

  def create
    @plant = Plant.find(params[:plant_id])
    @care_parameter = @plant.care_parameters.build(care_parameter_params)

    if @care_parameter.save
      redirect_to plant_path(@plant), notice: "Parâmetro de cuidado adicionado com sucesso!"
    else
      redirect_to plant_path(@plant), alert: "Erro ao adicionar parâmetro."
    end
  end

  def destroy
    @care_parameter = CareParameter.find(params[:id])
    @plant = @care_parameter.plant
    @care_parameter.destroy
    redirect_to plant_path(@plant), notice: "Parâmetro removido."
  end

  private

  def care_parameter_params
    params.require(:care_parameter).permit(:action_type, :interval_days)
  end
end
