class DashboardController < ApplicationController
  def index
    @plants = current_user.plants
                          .includes(:care_parameters, :care_logs, { photo_attachment: :blob })
                          .order(:name)

    @total_plants = @plants.count
    @needs_watering = @plants.count(&:needs_watering?)
    @needs_fertilization = @plants.count(&:needs_fertilization?)
    @needs_pest_control = @plants.count(&:needs_pest_control?)
    @plants_needing_care = @plants.select(&:needs_any_care?)
  end
end
