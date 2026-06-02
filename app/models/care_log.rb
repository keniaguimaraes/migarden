class CareLog < ApplicationRecord
  belongs_to :plant

  enum :action_type, { watering: 0, fertilization: 1, insecticide: 2 }, prefix: true

  validates :action_type, :performed_at, presence: true
end
