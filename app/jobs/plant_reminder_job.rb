class PlantReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(plants: [:care_parameters, :care_logs]).find_each do |user|
      next unless user.callmebot_phone.present? && user.callmebot_api_key.present?

      user.plants.each do |plant|
        message = build_message(plant)
        next if message.nil?

        WhatsappNotifier.send_message(user, message)
      end
    end
  rescue StandardError => e
    Rails.logger.error("[PlantReminderJob] Error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace&.first(10)&.join("\n"))
    raise
  ensure
    reschedule_for_next_8am
  end

  def self.reschedule_for_next_8am
    set(wait_until: next_run_at).perform_later
  end

  def self.next_run_at(now: Time.current)
    target = now.in_time_zone.change(hour: 8, min: 0, sec: 0)
    target += 1.day if target <= now
    target
  end

  private

  def reschedule_for_next_8am
    self.class.reschedule_for_next_8am
  end

  def build_message(plant)
    pending_cares = []
    pending_cares << "regar"               if plant.needs_watering?
    pending_cares << "fertilizar"          if plant.needs_fertilization?
    pending_cares << "fazer controle de pragas" if plant.needs_pest_control?

    return nil if pending_cares.empty?

    <<~MSG
      🌱 Lembrete do migarden

      Planta: #{plant.name}
      Tipo: #{plant.plant_type}
      Hoje é dia de: #{pending_cares.to_sentence}

      💧 Próxima rega: #{plant.next_watering_date.strftime("%d/%m/%Y")}
      🧪 Próxima fertilização: #{plant.next_fertilization_date.strftime("%d/%m/%Y")}
      🐛 Próximo controle de pragas: #{plant.next_pest_control_date.strftime("%d/%m/%Y")}
    MSG
  end
end
