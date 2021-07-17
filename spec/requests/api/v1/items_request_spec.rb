require 'rails_helper'

RSpec.describe 'Items API' do
  describe 'index' do
    it 'returns a list of all items with a default of 20 max and page 1' do
      create_list(:item, 50)

      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(20)
      expect(items.first[:id].to_i).to eq(Item.first.id)
    end

    it 'takes query params for per page and page, returing accurate data' do
      create_list(:item, 200)

      get '/api/v1/items?per_page=50&page=2'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(50)
      expect(items.first[:id].to_i).to eq(Item.first.id + 50)

      get '/api/v1/items?per_page=50&page=3'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(50)
      expect(items.first[:id].to_i).to eq(Item.first.id + 100)
    end

    it 'defaults to page 1 if page given is less than or eq to 0' do
      create_list(:item, 30)

      get '/api/v1/items?page=0'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(20)
      expect(items.first[:id].to_i).to eq(Item.first.id)
    end

    it 'returns an empty array of data for 0 results' do
      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(0)
      expect(items).to eq([])
    end
  end
end
