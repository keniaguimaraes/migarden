require 'rails_helper'

RSpec.describe 'CareLogs API', type: :request do
  let(:plant) { Plant.create!(name: 'Test Plant') }
  let(:parameter) { CareParameter.create!(plant: plant, action_type: 'watering', interval_days: 10) }

  describe 'POST /care_logs' do
    it 'creates a care log' do
      params = {
        care_log: {
          plant_id: plant.id,
          care_parameter_id: parameter.id,
          performed_at: Time.current
        }
      }

      post '/care_logs', params: params

      expect(response).to have_http_status(:created)
      expect(CareLog.count).to eq(1)
    end

    it 'triggers frequency adjustment when care is performed early' do
      # First log to establish a baseline
      initial_log = CareLog.create!(
        plant: plant,
        care_parameter: parameter,
        performed_at: 13.days.ago
      )

      # Expected date for next care is 3 days ago (initial_log.performed_at + 10 days)
      # If we perform it now (3 days late? no, that's not early)

      # Let's use absolute dates for clarity in the test
      # initial_log: April 10
      # interval: 10
      # expected: April 20
      # actual: April 17 (3 days early)

      # We'll use a fixed point in time
      base_date = Date.today - 10.days
      initial_log.update!(performed_at: base_date.to_time)

      # Expected: base_date + 10 = Today
      # Actual: Today - 3 days
      early_date = (Date.today - 3.days).to_time

      params = {
        care_log: {
          plant_id: plant.id,
          care_parameter_id: parameter.id,
          performed_at: early_date
        }
      }

      # We need to ensure CareCalculatorService.adjust_frequency is called
      # The test verifies the side effect on CareParameter
      post '/care_logs', params: params

      expect(response).to have_http_status(:created)

      # days_diff = (expected - actual) = (10 days ago + 10) - (7 days ago) = 0 - (-7) = 7?
      # Wait, let's trace the service logic:
      # expected_date = last_log.performed_at.to_date + parameter.interval_days.days
      # days_diff = (expected_date - actual_date.to_date).to_i
      # if days_diff >= 2, new_interval = parameter.interval_days - days_diff

      # Case:
      # initial_log: 2026-04-19
      # interval: 10
      # expected: 2026-04-29
      # actual: 2026-04-26 (3 days early)
      # days_diff = 29 - 26 = 3
      # new_interval = 10 - 3 = 7

      expect(parameter.reload.interval_days).to eq(7)
    end
  end
end
