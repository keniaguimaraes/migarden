class CareParameter < ApplicationRecord
  belongs_to :plant

  enum :action_type, { watering: 0, fertilization: 1, insecticide: 2 }, prefix: true

  validates :action_type, presence: true
  validates :interval_days, presence: true, numericality: { greater_than: 0 }
end
