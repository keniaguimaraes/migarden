class UpdatePlantsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :plants, :species, :string
    add_column :plants, :nickname, :string

    remove_column :plants, :watering_frequency_days, :integer
    remove_column :plants, :fertilization_frequency_days, :integer
    remove_column :plants, :pest_control_frequency_days, :integer
    remove_column :plants, :last_watered_at, :date
    remove_column :plants, :last_fertilized_at, :date
    remove_column :plants, :last_pest_control_at, :date
  end
end
