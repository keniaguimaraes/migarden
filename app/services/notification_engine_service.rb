class NotificationEngineService
  ACTION_LABELS = {
    'watering' => 'Rega',
    'fertilization' => 'Fertilização',
    'insecticide' => 'Inseticida'
  }.freeze

  def self.call
    due_parameters = []
    CareParameter.includes(:plant).find_each do |parameter|
      due_parameters << parameter if CareCalculatorService.due_today(parameter)
    end

    return if due_parameters.empty?

    grouped_tasks = due_parameters.group_by do |parameter|
      parameter.action_type
    end

    message = build_message(grouped_tasks)

    WhatsApp::SendNotificationService.call(
      ENV['USER_PHONE'],
      message
    )
  end

  private

  def self.build_message(grouped_tasks)
    header = "Olá! Hoje é dia de cuidar do seu jardim 🌿\n\n"

    body = grouped_tasks.map do |action, parameters|
      label = ACTION_LABELS[action] || action.capitalize
      plants = parameters.map { |p| p.plant.name }.join(', ')
      "#{label}: #{plants}"
    end.join("\n")

    "#{header}#{body}\n\nTenha um ótimo dia! ☀️"
  end
end
