require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Whatsapp::SendNotificationService do
  let(:number) { '5511999999999' }
  let(:text) { 'Hello from miGarden!' }
  let(:image_url) { 'https://example.com/image.jpg' }
  let(:api_url) { 'https://api.evolution.com' }
  let(:instance) { 'my-instance' }
  let(:api_key) { 'test-api-key' }

  before do
    stub_const('ENV', ENV.to_h.merge(
      'EVOLUTION_API_URL' => api_url,
      'EVOLUTION_INSTANCE' => instance,
      'EVOLUTION_API_KEY' => api_key
    ))
  end

  let(:endpoint) { "#{api_url}/message/sendText/#{instance}" }

  describe '.call' do
    context 'without image' do
      it 'sends a POST request to the Evolution API' do
        stub_request(:post, endpoint)
          .with(
            headers: {
              'apikey' => api_key,
              'Content-Type' => 'application/json'
            },
            body: { number: number, text: text }.to_json
          )
          .to_return(status: 200, body: { message: 'success' }.to_json)

        result = described_class.call(number, text)

        expect(result).to be true
        expect(WebMock).to have_requested(:post, endpoint)
      end
    end

    context 'with image' do
      it 'includes the media field in the payload' do
        stub_request(:post, endpoint)
          .with(
            headers: {
              'apikey' => api_key,
              'Content-Type' => 'application/json'
            },
            body: { number: number, text: text, media: image_url }.to_json
          )
          .to_return(status: 200, body: { message: 'success' }.to_json)

        result = described_class.call(number, text, image_url)

        expect(result).to be true
        expect(WebMock).to have_requested(:post, endpoint)
      end
    end

    context 'when the API returns an error' do
      it 'returns false' do
        stub_request(:post, endpoint).to_return(status: 500)

        result = described_class.call(number, text)

        expect(result).to be false
      end
    end

    context 'when a connection error occurs' do
      it 'handles Faraday::ConnectionFailed and returns false' do
        stub_request(:post, endpoint).to_raise(Faraday::ConnectionFailed.new('Connection failed'))

        result = described_class.call(number, text)

        expect(result).to be false
      end

      it 'handles Faraday::TimeoutError and returns false' do
        stub_request(:post, endpoint).to_raise(Faraday::TimeoutError.new('Request timed out'))

        result = described_class.call(number, text)

        expect(result).to be false
      end
    end
  end
end
