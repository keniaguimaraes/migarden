class Plant < ApplicationRecord
  has_many :care_parameters, dependent: :destroy
  has_many :care_logs, dependent: :destroy

  validates :name, presence: true
end
