require "net/http"
require "uri"

class WhatsappNotifier
  ENDPOINT = "https://api.callmebot.com/whatsapp.php".freeze

  def self.send_message(user, message)
    new(user, message).send_message
  end

  def initialize(user, message)
    @user = user
    @message = message
  end

  def send_message
    return log_skip("missing credentials") unless credentials_present?

    uri = build_uri
    Rails.logger.info("[WhatsappNotifier] Sending to #{@user.callmebot_phone}: #{@message[0..50]}...")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      body = response.body.to_s.force_encoding("UTF-8")
      Rails.logger.info("[WhatsappNotifier] ✅ Success for #{@user.email}: #{body[0..100]}")
    else
      body = response&.body.to_s.force_encoding("UTF-8")
      Rails.logger.error("[WhatsappNotifier] ❌ Error (#{response&.code}) for #{@user.email}: #{body}")
    end

    response
  rescue StandardError => e
    Rails.logger.error("[WhatsappNotifier] ❌ Unexpected error for #{@user.email}: #{e.class} - #{e.message}")
    nil
  end

  private

  def credentials_present?
    @user.callmebot_phone.present? && @user.callmebot_api_key.present?
  end

  def build_uri
    uri = URI(ENDPOINT)
    phone = @user.callmebot_phone
    phone = "+#{phone}" unless phone.start_with?("+")
    
    uri.query = URI.encode_www_form(
      phone: phone,
      text: @message,
      apikey: @user.callmebot_api_key
    )
    uri
  end

  def log_skip(reason)
    Rails.logger.info("[WhatsappNotifier] Skipping notification for #{@user.email}: #{reason}")
    nil
  end
end
