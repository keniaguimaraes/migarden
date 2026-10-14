require 'net/http'
require 'uri'
require 'json'

class TelegramNotifier
  API_BASE = 'https://api.telegram.org'.freeze

  def self.send_message(user, message)
    new(user, message).send_message
  end

  def self.fetch_chat_id
    token = ENV.fetch('TELEGRAM_BOT_TOKEN', '').to_s
    return nil if token.empty?

    response = Net::HTTP.get_response(URI("#{API_BASE}/bot#{token}/getUpdates"))
    return nil unless response.is_a?(Net::HTTPSuccess)

    latest_chat_id(response.body)
  rescue StandardError => e
    Rails.logger.error("[TelegramNotifier] fetch_chat_id error: #{e.class} - #{e.message}")
    nil
  end

  def self.latest_chat_id(body)
    updates = JSON.parse(body)['result'] || []
    chats = updates.reverse.filter_map { |update| (update['message'] || update['edited_message'])&.dig('chat') }
    chats.first&.dig('id')&.to_s
  end

  def initialize(user, message)
    @user = user
    @message = message
  end

  def send_message
    return log_skip('missing chat id') if @user.telegram_chat_id.blank?
    return log_skip('missing bot token') if bot_token.empty?

    response = perform_request
    log_response(response)
    response
  rescue StandardError => e
    Rails.logger.error("[TelegramNotifier] Unexpected error for #{@user.email}: #{e.class} - #{e.message}")
    nil
  end

  private

  def bot_token
    ENV.fetch('TELEGRAM_BOT_TOKEN', '').to_s
  end

  def perform_request
    uri = URI("#{API_BASE}/bot#{bot_token}/sendMessage")
    Rails.logger.info("[TelegramNotifier] Sending to #{@user.telegram_chat_id}: #{@message[0..50]}...")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri)
    request.set_form_data(chat_id: @user.telegram_chat_id, text: @message)
    http.request(request)
  end

  def log_response(response)
    body = response&.body.to_s.force_encoding('UTF-8')
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("[TelegramNotifier] ✅ Success for #{@user.email}")
    else
      Rails.logger.error("[TelegramNotifier] ❌ Error (#{response&.code}) for #{@user.email}: #{body[0..200]}")
    end
  end

  def log_skip(reason)
    Rails.logger.info("[TelegramNotifier] Skipping notification for #{@user.email}: #{reason}")
    nil
  end
end
