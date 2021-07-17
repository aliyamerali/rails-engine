require 'rails_helper'

RSpec.describe 'Merchants API' do
  describe 'index' do
    it 'returns a list of all merchants with a default of 20 max and page 1' do
      create_list(:merchant, 50)

      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(20)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id)

      expect(merchants.first[:attributes]).to have_key(:name)
      expect(merchants.first[:attributes][:name]).to be_a(String)
    end

    it 'takes query params for per page and page, returing accurate data' do
      create_list(:merchant, 200)

      get '/api/v1/merchants?per_page=50&page=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id + 50)

      expect(merchants.first[:attributes]).to have_key(:name)
      expect(merchants.first[:attributes][:name]).to be_a(String)

      get '/api/v1/merchants?per_page=50&page=3'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id + 100)

      expect(merchants.first[:attributes]).to have_key(:name)
      expect(merchants.first[:attributes][:name]).to be_a(String)
    end

    it 'defaults to page 1 if page given is less than or eq to 0' do
      create_list(:merchant, 30)

      get '/api/v1/merchants?page=0'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(20)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:id].to_i).to eq(Merchant.first.id)

      expect(merchants.first[:attributes]).to have_key(:name)
      expect(merchants.first[:attributes][:name]).to be_a(String)
    end

    it 'returns an empty array of data for 0 results' do
      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(0)
      expect(merchants).to eq([])
    end
  end

  describe 'show - fetch a single record' do
    it 'returns the record requested if it exists' do
      create(:merchant)
      merchant = Merchant.first

      get "/api/v1/merchants/#{merchant.id}"
      output = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful

      expect(output).to have_key(:id)
      expect(output[:id].to_i).to eq(merchant.id)

      expect(output[:attributes]).to have_key(:name)
      expect(output[:attributes][:name]).to be_a(String)
    end

    it 'returns 404 if no record exists' do
      get '/api/v1/merchants/12'

      expect(response.status).to eq(404)
    end
  end
end
