class Plant < ApplicationRecord
  belongs_to :user
  has_one_attached :photo

  validates :name, :plant_type, :sun_exposure, presence: true
  validates :watering_frequency_days, :fertilization_frequency_days, :pest_control_frequency_days,
            presence: true, numericality: { greater_than: 0 }

  def next_watering_date
    return Date.current if last_watered_at.blank?
    last_watered_at + watering_frequency_days.days
  end

  def next_fertilization_date
    return Date.current if last_fertilized_at.blank?
    last_fertilized_at + fertilization_frequency_days.days
  end

  def next_pest_control_date
    return Date.current if last_pest_control_at.blank?
    last_pest_control_at + pest_control_frequency_days.days
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
end
