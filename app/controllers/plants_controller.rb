class PlantsController < ApplicationController
  before_action :set_plant, only: [
    :show, :edit, :update, :destroy,
    :mark_as_watered, :mark_as_fertilized, :mark_as_pest_controlled
  ]

  def index
    @plants = current_user.plants
                            .includes(:care_parameters, :care_logs, { photo_attachment: :blob })
                            .order(:name)
  end

  def show
    @care_logs = @plant.care_logs.includes(:plant).order(performed_at: :desc).limit(10)
  end

  def new
    @plant = current_user.plants.build
    @plant.care_parameters.build(action_type: :watering)
    @plant.care_parameters.build(action_type: :fertilization)
    @plant.care_parameters.build(action_type: :insecticide)
  end

  def create
    @plant = current_user.plants.build(plant_params)

    if @plant.save
      sync_care_parameters(@plant)
      redirect_to @plant, notice: "Planta cadastrada com sucesso!"
    else
      ensure_care_parameter_placeholders(@plant)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    ensure_care_parameter_placeholders(@plant)
  end

  def update
    if @plant.update(plant_params)
      sync_care_parameters(@plant)
      redirect_to @plant, notice: "Planta atualizada com sucesso!"
    else
      ensure_care_parameter_placeholders(@plant)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy
    redirect_to plants_path, notice: "Planta removida com sucesso."
  end

  def mark_as_watered
    register_care(:watering, "Planta marcada como regada.")
  end

  def mark_as_fertilized
    register_care(:fertilization, "Planta marcada como fertilizada.")
  end

  def mark_as_pest_controlled
    register_care(:insecticide, "Controle de pragas registrado.")
  end

  private

  def set_plant
    @plant = current_user.plants.find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(
      :name, :plant_type, :sun_exposure, :species, :nickname, :photo
    )
  end

  def interval_for(action_type)
    case action_type
    when :watering       then params[:plant][:watering_interval_days]
    when :fertilization  then params[:plant][:fertilization_interval_days]
    when :insecticide    then params[:plant][:pest_control_interval_days]
    end
  end

  def sync_care_parameters(plant)
    mapping = { watering: :watering_interval_days,
                fertilization: :fertilization_interval_days,
                insecticide: :pest_control_interval_days }

    mapping.each do |action_type, param_key|
      value = params.dig(:plant, param_key)
      next if value.blank?

      parameter = plant.care_parameters.find_or_initialize_by(action_type: action_type)
      parameter.interval_days = value.to_i
      parameter.save
    end
  end

  def ensure_care_parameter_placeholders(plant)
    %i[watering fertilization insecticide].each do |action_type|
      next if plant.care_parameters.any? { |cp| cp.action_type == action_type.to_s }
      plant.care_parameters.build(action_type: action_type)
    end
  end

  def register_care(action_type, success_message)
    @plant.care_logs.create!(action_type: action_type, performed_at: Date.current)
    redirect_to @plant, notice: success_message
  end
end
