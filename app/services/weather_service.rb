require 'net/http'
require 'json'
require 'uri'

class WeatherService
  DEFAULT_LATITUDE = -12.9714  # Salvador, BA
  DEFAULT_LONGITUDE = -38.5014

  class << self
    def current_temperature
      new.current_temperature
    end

    def adjusted_watering_interval(base_interval, temperature = current_temperature)
      return base_interval if base_interval.blank? || temperature.blank?

      case temperature
      when 32.. then [base_interval - 2, 1].max
      when 28...32 then [base_interval - 1, 1].max
      when ..19 then base_interval + 2
      else base_interval
      end
    end
  end

  def current_temperature
    return ENV['WEATHER_TEMPERATURE'].to_f if ENV['WEATHER_TEMPERATURE'].present?
    return nil if Rails.env.test?

    cached = Rails.cache.read(cache_key)
    return cached unless cached.nil?

    fetch_temperature
  rescue StandardError => e
    Rails.logger.error("[WeatherService] Erro ao buscar temperatura: #{e.message}")
    nil
  end

  private

  def fetch_temperature
    uri = URI('https://api.open-meteo.com/v1/forecast')
    uri.query = URI.encode_www_form(
      latitude: latitude,
      longitude: longitude,
      current: 'temperature_2m',
      daily: 'temperature_2m_max',
      forecast_days: 1,
      timezone: 'America/Bahia'
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    temperature = data.dig('daily', 'temperature_2m_max', 0)
    temperature = data.dig('current', 'temperature_2m') if temperature.nil?

    Rails.cache.write(cache_key, temperature, expires_in: 1.hour) if temperature
    temperature
  rescue StandardError => e
    Rails.logger.error("[WeatherService] Falha na requisição: #{e.message}")
    nil
  end

  def latitude
    ENV.fetch('WEATHER_LATITUDE', DEFAULT_LATITUDE).to_f
  end

  def longitude
    ENV.fetch('WEATHER_LONGITUDE', DEFAULT_LONGITUDE).to_f
  end

  def cache_key
    "weather:temperature:#{latitude}:#{longitude}"
  end
end