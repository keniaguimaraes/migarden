require 'rails_helper'
require 'whatsapp/send_notification_service'

RSpec.describe NotificationEngineService, type: :service do
  let(:user_phone) { '5511999999999' }
  let(:plant_a) { Plant.create!(name: 'Samambaia') }
  let(:plant_b) { Plant.create!(name: 'Jiboia') }
  let(:plant_c) { Plant.create!(name: 'Orquídea') }

  before do
    allow(ENV).to receive(:[]).with('USER_PHONE').and_return(user_phone)
  end

  describe '.call' do
    context 'when no tasks are due' do
      it 'does not send any notification' do
        expect(WhatsApp::SendNotificationService).not_to receive(:call)
        NotificationEngineService.call
      end
    end

    context 'when multiple tasks are due' do
      let!(:param_a_water) { CareParameter.create!(plant: plant_a, action_type: :watering, interval_days: 7) }
      let!(:param_b_water) { CareParameter.create!(plant: plant_b, action_type: :watering, interval_days: 7) }
      let!(:param_c_fert) { CareParameter.create!(plant: plant_c, action_type: :fertilization, interval_days: 30) }

      before do
        # Mock CareCalculatorService to return true for these specific parameters
        allow(CareCalculatorService).to receive(:due_today).with(param_a_water).and_return(true)
        allow(CareCalculatorService).to receive(:due_today).with(param_b_water).and_return(true)
        allow(CareCalculatorService).to receive(:due_today).with(param_c_fert).and_return(true)
      end

      it 'sends a consolidated message in Portuguese' do
        expect(WhatsApp::SendNotificationService).to receive(:call).with(
          user_phone,
          a_string_matching(/Olá! Hoje é dia de cuidar do seu jardim/)
        )

        NotificationEngineService.call
      end

      it 'groups plants by action type' do
        # We expect the message to contain "Rega" with Samambaia and Jiboia, and "Fertilização" with Orquídea
        # Action types are :watering, :fertilization, :insecticide
        # Human labels: Rega, Fertilização, Inseticida

        expect(WhatsApp::SendNotificationService).to receive(:call).with(
          user_phone,
          a_string_matching(/Rega: Samambaia, Jiboia.*Fertilização: Orquídea|Fertilização: Orquídea.*Rega: Samambaia, Jiboia/m)
        )

        NotificationEngineService.call
      end
    end

    context 'when only one plant is due' do
      let!(:param_a_water) { CareParameter.create!(plant: plant_a, action_type: :watering, interval_days: 7) }

      before do
        allow(CareCalculatorService).to receive(:due_today).with(param_a_water).and_return(true)
      end

      it 'sends a notification for that single plant' do
        expect(WhatsApp::SendNotificationService).to receive(:call).with(
          user_phone,
          include('Rega: Samambaia')
        )

        NotificationEngineService.call
      end
    end
  end
end
