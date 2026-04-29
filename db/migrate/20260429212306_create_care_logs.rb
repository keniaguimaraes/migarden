class CreateCareLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :care_logs do |t|
      t.references :plant, null: false, foreign_key: true
      t.references :care_parameter, null: false, foreign_key: true
      t.date :performed_at
      t.text :observation

      t.timestamps
    end
  end
end
