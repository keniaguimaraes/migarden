class CareLogsController < ApplicationController
  def create
    @care_log = CareLog.new(care_log_params)

    if @care_log.save
      # Critical Logic: Adjust frequency if action performed early
      CareCalculatorService.adjust_frequency(@care_log.care_parameter, @care_log.performed_at)

      render json: @care_log, status: :created
    else
      render json: @care_log.errors, status: :unprocessable_entity
    end
  end

  private

  def care_log_params
    params.require(:care_log).permit(:plant_id, :care_parameter_id, :performed_at)
  end
end
