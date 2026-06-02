class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :name
      t.string :plant_type
      t.string :sun_exposure
      t.integer :watering_frequency_days
      t.integer :fertilization_frequency_days
      t.integer :pest_control_frequency_days
      t.date :last_watered_at
      t.date :last_fertilized_at
      t.date :last_pest_control_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
