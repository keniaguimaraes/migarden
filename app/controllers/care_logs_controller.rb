class CareLogsController < ApplicationController
  def create
    @care_log = CareLog.new(care_log_params)

    if @care_log.save
      # Gatilho para ajuste dinâmico de frequência
      CareCalculatorService.adjust_frequency(@care_log.care_parameter, @care_log.performed_at)

      respond_to do |format|
        format.html { redirect_to plant_path(@care_log.plant, notice: "Cuidado registrado com sucesso!"), status: :see_other }
        format.json { render json: @care_log, status: :created }
      end
    else
      render json: { errors: @care_log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def care_log_params
    params.require(:care_log).permit(:plant_id, :care_parameter_id, :performed_at, :observation)
  end
end
