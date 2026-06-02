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
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[WhatsappNotifier] Error sending to #{@user.email}: #{response.body}")
    end

    response
  rescue StandardError => e
    Rails.logger.error("[WhatsappNotifier] Unexpected error: #{e.message}")
    nil
  end

  private

  def credentials_present?
    @user.callmebot_phone.present? && @user.callmebot_api_key.present?
  end

  def build_uri
    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form(
      phone: @user.callmebot_phone,
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
