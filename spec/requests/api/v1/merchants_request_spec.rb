require 'rails_helper'

RSpec.describe 'Merchants API' do
  describe 'index' do
    it 'returns a list of all merchants with a default of 20 max and page 1' do
      create_list(:merchant, 50)

      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body)

      expect(merchants.count).to eq(20)
      expect(merchants.first.id).to eq(Merchant.all.first.id)
    end
  end
end
