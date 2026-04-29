require 'rails_helper'

RSpec.describe CareCalculatorService, type: :service do
  let(:plant) { Plant.create!(name: 'Fern') }
  let(:care_parameter) { CareParameter.create!(plant: plant, action_type: :watering, interval_days: 7) }

  describe '.due_today' do
    context 'when no care logs exist' do
      it 'returns true' do
        expect(CareCalculatorService.due_today(care_parameter)).to be true
      end
    end

    context 'when a care log exists' do
      it 'returns true if the interval has passed' do
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 7.days)
        expect(CareCalculatorService.due_today(care_parameter)).to be true
      end

      it 'returns true if today is exactly the scheduled date' do
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 7.days)
        # interval is 7, so performed_at + 7 == today
        expect(CareCalculatorService.due_today(care_parameter)).to be true
      end

      it 'returns false if the interval has not yet passed' do
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 6.days)
        expect(CareCalculatorService.due_today(care_parameter)).to be false
      end
    end
  end

  describe '.adjust_frequency' do
    context 'when action is performed early' do
      it 'reduces interval_days if performed 2 or more days early' do
        # Last log was 7 days ago, interval is 7. Expected today.
        # If we perform it today, it's not early.
        # To be 2 days early, it must be performed at (expected_date - 2)
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 7.days)

        # Expected date = (Date.today - 7) + 7 = Date.today
        # Actual date = Date.today - 2
        actual_date = Date.today - 2.days

        CareCalculatorService.adjust_frequency(care_parameter, actual_date)

        # diff = 2. interval = 7 - 2 = 5
        expect(care_parameter.reload.interval_days).to eq(5)
      end

      it 'does not reduce interval_days if performed only 1 day early' do
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 7.days)
        actual_date = Date.today - 1.day

        CareCalculatorService.adjust_frequency(care_parameter, actual_date)

        expect(care_parameter.reload.interval_days).to eq(7)
      end

      it 'does not reduce interval_days if performed on or after expected date' do
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 7.days)
        actual_date = Date.today

        CareCalculatorService.adjust_frequency(care_parameter, actual_date)

        expect(care_parameter.reload.interval_days).to eq(7)
      end
    end

    context 'when interval is already low' do
      it 'ensures interval_days does not drop below 1' do
        care_parameter.update!(interval_days: 2)
        CareLog.create!(plant: plant, care_parameter: care_parameter, performed_at: Date.today - 2.days)

        # Expected today. Actual 3 days ago. Diff = 3.
        # 2 - 3 = -1. Should be clamped to 1.
        actual_date = Date.today - 3.days

        CareCalculatorService.adjust_frequency(care_parameter, actual_date)

        expect(care_parameter.reload.interval_days).to eq(1)
      end
    end
  end
end
