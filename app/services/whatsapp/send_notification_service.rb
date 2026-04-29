module WhatsApp
  class SendNotificationService
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
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.headers['apikey'] = ENV['EVOLUTION_API_KEY']
        f.headers['Content-Type'] = 'application/json'
        f.adapter Faraday.default_adapter
      end
    end

    def endpoint
      "#{ENV['EVOLUTION_API_URL']}/message/sendText/#{ENV['EVOLUTION_INSTANCE']}"
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
