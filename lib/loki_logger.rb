require 'net/http'
require 'json'

class LokiLogger
  def initialize
    raw_url = ENV.fetch('LOKI_URL', nil)
    @url = raw_url&.sub(%r{/loki/api/v1/push$}, '')
    @username = ENV.fetch('LOKI_USERNAME', nil)
    @token = ENV.fetch('LOKI_TOKEN', nil)
    @buffer = []
    @mutex = Mutex.new
    return unless active?

    if @token.blank?
      Rails.logger.warn('[LokiLogger] LOKI_URL set but LOKI_TOKEN missing')
    else
      Rails.logger.info("[LokiLogger] Attached, shipping logs to #{@url}")
    end
    start_flusher
  end

  def add(severity, message = nil, progname = nil, &block)
    return unless active?

    msg = message || block&.call || progname
    return if msg.blank?

    @mutex.synchronize do
      @buffer << { ts: (Time.now.to_f * 1_000_000_000).to_i, msg: msg.to_s, level: severity_name(severity) }
    end
  end

  def close
    flush
  end

  def silence(*_args, &)
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
    entries = drain_buffer
    return if entries.blank?

    payload = build_payload(entries)
    push(payload)
  end

  def drain_buffer
    entries = nil
    @mutex.synchronize do
      entries = @buffer.dup
      @buffer.clear
    end
    entries
  end

  def build_payload(entries)
    values = entries.map do |e|
      log_entry = { message: e[:msg], level: e[:level] }
      [e[:ts], JSON.generate(log_entry)]
    end

    {
      streams: [
        {
          stream: { app: 'migarden', env: Rails.env },
          values: values
        }
      ]
    }
  end

  def push(payload)
    uri = URI("#{@url}/loki/api/v1/push")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = 2
    http.read_timeout = 2

    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    req.basic_auth(@username, @token) if @username.present?
    req.body = payload.to_json
    http.request(req)
  rescue StandardError => e
    warn("[LokiLogger] Push failed: #{e.message}")
  end

  def severity_name(severity)
    case severity
    when Logger::DEBUG then 'debug'
    when Logger::INFO then 'info'
    when Logger::WARN then 'warn'
    when Logger::ERROR then 'error'
    when Logger::FATAL then 'fatal'
    else 'unknown'
    end
  end
end
