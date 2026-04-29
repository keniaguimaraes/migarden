class CareLog < ApplicationRecord
  belongs_to :plant
  belongs_to :care_parameter

  # The action_type is inherited from the associated care_parameter
  delegate :action_type, to: :care_parameter
end
