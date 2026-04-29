class DailyNotificationJob < ApplicationJob
  queue_as :default

  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 5

  def perform
    begin
      NotificationEngineService.call
    rescue StandardError => e
      Rails.logger.error "DailyNotificationJob failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
