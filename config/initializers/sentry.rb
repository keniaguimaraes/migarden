if ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.enabled_environments = %w[production]
    config.traces_sample_rate = 0.0
  end
end
