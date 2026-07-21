if Rails.env.production?
  Rails.application.config.lograge.enabled = true
  Rails.application.config.lograge.formatter = Lograge::Formatters::Json.new

  Rails.application.config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params].except("controller", "action"),
      request_id: event.payload[:request_id]
    }
  end

  Rails.application.config.lograge.ignore_actions = ["Rails::HealthController#show"]
end
