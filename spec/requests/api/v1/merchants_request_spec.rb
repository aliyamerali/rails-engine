require 'rails_helper'

RSpec.describe 'Merchants API' do
  describe 'index' do
    it 'returns a list of all merchants with a default of 20 max and page 1' do
      create_list(:merchant, 50)

      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(20)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id)
    end

    it 'takes query params for per page and page, returing accurate data' do
      create_list(:merchant, 200)

      get '/api/v1/merchants?per_page=50&page=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)
      expect(merchants.first[:id].to_i).to eq(151)

      get '/api/v1/merchants?per_page=50&page=3'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)
      expect(merchants.first[:id].to_i).to eq(201)
    end

    it 'defaults to page 1 if page given is less than or eq to 0' do
      create_list(:merchant, 30)

      get '/api/v1/merchants?page=0'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(20)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id)
    end

    it 'returns an empty array of data for 0 results' do
      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(0)
      expect(merchants).to eq([])
    end
  end
end
