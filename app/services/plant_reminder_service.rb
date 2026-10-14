class PlantReminderService
  def self.call
    new.call
  end

  def call
    User.includes(plants: %i[care_parameters care_logs]).find_each do |user|
      process_user(user)
    end
  end

  private

  def process_user(user)
    return if user.telegram_chat_id.blank?

    user.plants.each do |plant|
      message = build_message(plant)
      next if message.nil?

      TelegramNotifier.send_message(user, message)
    end
  end

  def build_message(plant)
    pending_cares = []
    pending_cares << 'regar'                    if plant.needs_watering?
    pending_cares << 'fertilizar'               if plant.needs_fertilization?
    pending_cares << 'fazer controle de pragas' if plant.needs_pest_control?

    return nil if pending_cares.empty?

    <<~MSG
      🌱 Lembrete do migarden

      Planta: #{plant.name}
      Tipo: #{plant.plant_type}
      Hoje é dia de: #{pending_cares.to_sentence}

      💧 Próxima rega: #{plant.next_watering_date.strftime('%d/%m/%Y')}
      🧪 Próxima fertilização: #{plant.next_fertilization_date.strftime('%d/%m/%Y')}
      🐛 Próximo controle de pragas: #{plant.next_pest_control_date.strftime('%d/%m/%Y')}
    MSG
  end
end
