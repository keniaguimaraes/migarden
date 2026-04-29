class CareParameter < ApplicationRecord
  belongs_to :plant

  enum action_type: { watering: 0, fertilization: 1, insecticide: 2 }

  validates :action_type, :interval_days, presence: true
end
