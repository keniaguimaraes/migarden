class DailyNotificationJob < ApplicationJob
  queue_as :default

  def perform
    NotificationEngineService.call
  end
end
