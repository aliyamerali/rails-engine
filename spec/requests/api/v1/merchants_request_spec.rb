require 'rails_helper'

RSpec.describe 'Merchants API' do
  describe 'index' do
    it 'returns a list of all merchants with a default of 20 max and page 1' do
      create_list(:merchant, 50)

      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants.count).to eq(20)
      expect(merchants.first[:id]).to eq(Merchant.first.id)
    end

    it 'takes query params for per page and page, returing accurate data' do
      create_list(:merchant, 100)

      get '/api/v1/merchants?per_page=50&page=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants.count).to eq(50)
      expect(merchants.first[:id]).to eq(151)
    end
  end
end
