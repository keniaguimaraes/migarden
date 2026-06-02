class AlertsController < ApplicationController
  def index
    plants_scope = current_user.plants
                                .includes(:care_parameters, :care_logs, { photo_attachment: :blob })

    @pending_plants = plants_scope.select(&:needs_any_care?).sort_by(&:name)
    @counts = {
      watering:      plants_scope.count(&:needs_watering?),
      fertilization: plants_scope.count(&:needs_fertilization?),
      pest_control:  plants_scope.count(&:needs_pest_control?)
    }
  end
end
