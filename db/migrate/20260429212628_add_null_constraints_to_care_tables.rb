class AddNullConstraintsToCareTables < ActiveRecord::Migration[7.0]
  def change
    change_column_null :plants, :name, false
    change_column_null :care_parameters, :action_type, false
    change_column_null :care_parameters, :interval_days, false
    change_column_null :care_logs, :performed_at, false
  end
end
