class CareCalculatorService
  def self.due_today(parameter)
    last_log = CareLog.where(care_parameter: parameter).order(performed_at: :desc).first

    return true if last_log.nil?

    expected_date = last_log.performed_at + parameter.interval_days.days
    expected_date.to_date <= Date.today
  end

  def self.adjust_frequency(parameter, actual_date)
    last_log = CareLog.where(care_parameter: parameter).order(performed_at: :desc).first
    return if last_log.nil?

    expected_date = last_log.performed_at.to_date + parameter.interval_days.days

    # Calculate the difference in days
    # actual_date is the date the care was performed
    days_diff = (expected_date - actual_date.to_date).to_i

    if days_diff >= 2
      new_interval = parameter.interval_days - days_diff
      parameter.update!(interval_days: [new_interval, 1].max)
    end
  end
end
