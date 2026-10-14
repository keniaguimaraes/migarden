class PlantReminderJob < ApplicationJob
  queue_as :default

  def perform
    PlantReminderService.call
  end
end
