namespace :migarden do
  desc 'Envia os lembretes de cuidado por WhatsApp (usado pelo agendador diario)'
  task reminders: :environment do
    Rails.logger.info('[migarden] Running PlantReminderService')
    PlantReminderService.call
  end
end
