class AddUniqueIndexToCareParameters < ActiveRecord::Migration[7.0]
  def change
    add_index :care_parameters, %i[action_type plant_id], unique: true
  end
end
