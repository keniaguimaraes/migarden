module Whatsapp
  class SendNotificationService
    API_URL = ENV['EVOLUTION_API_URL']
    INSTANCE = ENV['EVOLUTION_INSTANCE']
    API_KEY = ENV['EVOLUTION_API_KEY']

    def self.call(number, text, image_url = nil)
      new(number, text, image_url).call
    end

    def initialize(number, text, image_url)
      @number = number
      @text = text
      @image_url = image_url
    end

    def call
      response = connection.post(endpoint) do |req|
        req.body = payload.to_json
      end

      response.success?
    rescue Faraday::Error => e
      Rails.logger.error("[Whatsapp::SendNotificationService] Request failed: #{e.message}")
      Rails.logger.error("[Whatsapp::SendNotificationService] Response body: #{e.response[:body]}") if e.response
      false
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.headers['apikey'] = API_KEY
        f.headers['Content-Type'] = 'application/json'
        f.request :timeout, timeout: 5, open_timeout: 2
        f.adapter Faraday.default_adapter
      end
    end

    def endpoint
      "#{API_URL}/message/sendText/#{INSTANCE}"
    end

    def payload
      {
        number: @number,
        text: @text
      }.tap do |p|
        p[:media] = @image_url if @image_url.present?
      end
    end
  end
end
