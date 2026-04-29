require 'rails_helper'

RSpec.describe 'Plants API', type: :request do
  let(:plant_params) { { plant: { name: 'Monstera Deliciosa' } } }
  let(:image_file) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

  describe 'GET /plants' do
    it 'returns a list of plants' do
      Plant.create!(name: 'Plant 1')
      Plant.create!(name: 'Plant 2')

      get '/plants'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end
  end

  describe 'GET /plants/:id' do
    it 'returns a plant and its care parameters' do
      plant = Plant.create!(name: 'Ficus')
      CareParameter.create!(plant: plant, action_type: 'watering', interval_days: 7)

      get "/plants/#{plant.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Ficus')
      expect(json['care_parameters']).not_to be_empty
    end
  end

  describe 'POST /plants' do
    it 'creates a plant' do
      post '/plants', params: plant_params

      expect(response).to have_http_status(:created)
      expect(Plant.count).to eq(1)
      expect(Plant.last.name).to eq('Monstera Deliciosa')
    end

    it 'creates a plant with an image' do
      params = {
        plant: {
          name: 'Pothos',
          image: image_file
        }
      }

      post '/plants', params: params

      expect(response).to have_http_status(:created)
      plant = Plant.last
      expect(plant.image).to be_attached
    end
  end
end
