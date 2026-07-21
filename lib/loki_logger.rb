require "net/http"
require "json"

class LokiLogger
  def initialize
    @url = ENV.fetch("LOKI_URL", nil)
    @username = ENV.fetch("LOKI_USERNAME", nil)
    @token = ENV.fetch("LOKI_TOKEN", nil)
    @buffer = []
    @mutex = Mutex.new
    start_flusher if active?
  end

  def add(severity, message = nil, progname = nil, &block)
    return unless active?

    msg = message || (block && block.call) || progname
    return if msg.blank?

    @mutex.synchronize do
      @buffer << { ts: (Time.now.to_f * 1_000_000_000).to_i, msg: msg.to_s, level: severity_name(severity) }
    end
  end

  def close
    flush
  end

  def silence(*args, &block)
    yield
  end

  def level=(*); end
  def local_level=(*); end
  def formatter=(*); end
  def progname=(*); end
  def <<(msg)
    add(Logger::INFO, msg)
  end

  private

  def active?
    @url.present?
  end

  def start_flusher
    Thread.new do
      loop do
        sleep 3
        flush
      end
    end
  end

  def flush
    entries = nil
    @mutex.synchronize do
      entries = @buffer.dup
      @buffer.clear
    end
    return if entries.blank?

    values = entries.map do |e|
      log_entry = { message: e[:msg], level: e[:level] }
      [e[:ts], JSON.generate(log_entry)]
    end

    payload = {
      streams: [
        {
          stream: { app: "migarden", env: Rails.env },
          values: values
        }
      ]
    }

    uri = URI("#{@url}/loki/api/v1/push")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 2
    http.read_timeout = 2

    req = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
    req.basic_auth(@username, @token) if @username.present?
    req.body = payload.to_json
    http.request(req)
  rescue StandardError => e
    Rails.logger.error("[LokiLogger] Push failed: #{e.message}") if Rails.logger
  end

  def severity_name(severity)
    case severity
    when Logger::DEBUG then "debug"
    when Logger::INFO then "info"
    when Logger::WARN then "warn"
    when Logger::ERROR then "error"
    when Logger::FATAL then "fatal"
    else "unknown"
    end
  end
end
