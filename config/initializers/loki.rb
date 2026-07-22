if Rails.env.production? && ENV['LOKI_URL'].present?
  require Rails.root.join('lib/loki_logger')

  Rails.application.config.after_initialize do
    loki_logger = LokiLogger.new
    Rails.logger.extend(ActiveSupport::Logger.broadcast(loki_logger))
  end
end
