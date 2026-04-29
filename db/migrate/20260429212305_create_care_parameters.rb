class CreateCareParameters < ActiveRecord::Migration[7.0]
  def change
    create_table :care_parameters do |t|
      t.references :plant, null: false, foreign_key: true
      t.integer :action_type
      t.integer :interval_days

      t.timestamps
    end
  end
end
