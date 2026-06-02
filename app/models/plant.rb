class Plant < ApplicationRecord
  belongs_to :user
  has_many :care_parameters, dependent: :destroy
  has_many :care_logs, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true

  def next_watering_date
    calculate_next_date(:watering)
  end

  def next_fertilization_date
    calculate_next_date(:fertilization)
  end

  def next_pest_control_date
    calculate_next_date(:insecticide)
  end

  def needs_watering?
    next_watering_date <= Date.current
  end

  def needs_fertilization?
    next_fertilization_date <= Date.current
  end

  def needs_pest_control?
    next_pest_control_date <= Date.current
  end

  private

  def calculate_next_date(action_type)
    parameter = care_parameters.find_by(action_type: action_type)
    return Date.current unless parameter

    last_log = care_logs.where(action_type: action_type).order(performed_at: :desc).first
    return Date.current unless last_log

    last_log.performed_at + parameter.interval_days.days
  end
end
