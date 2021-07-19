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
      expect(merchants.first[:id].to_i).to_not eq(Merchant.first.id)

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

  describe 'returns the items associated with the merchant' do
    it 'returns merchant\'s items if merchant is found' do
      create(:merchant)
      merchant = Merchant.first
      create_list(:item, 50, merchant_id: merchant.id)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.length).to eq(50)
      expect(items.first).to have_key(:id)

      expect(items.first[:attributes]).to have_key(:name)
      expect(items.first[:attributes][:name]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:description)
      expect(items.first[:attributes][:description]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:unit_price)
      expect(items.first[:attributes][:unit_price]).to be_a(Float)

      expect(items.first[:attributes]).to have_key(:merchant_id)
      expect(items.first[:attributes][:merchant_id]).to eq(merchant.id)
    end

    it 'returns a 404 if merchant not found' do
      get "/api/v1/merchants/456788/items"

      expect(response.status).to eq(404)
    end
  end

  describe 'find one merchant based on name query param' do
    it 'returns a single merchant object, if found' do
      create(:merchant, name: "Turing School")
      create(:merchant, name: "Hoops Only")
      query_param = "ring"

      get "/api/v1/merchants/find?name=#{query_param}"

      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant.count).to eq(1)
      expect(merchant[:attributes][:name]).to eq("Turing School")
    end

    it 'returns first object in case-sensitive alpha order if multiple matches' do
      create(:merchant, name: "Turing School")
      create(:merchant, name: "Zesty Ringalings")
      create(:merchant, name: "Rings R Us")
      create(:merchant, name: "Hoops Only")

      get "/api/v1/merchants/find?name=#{query_param}"

      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant.count).to eq(1)
      expect(merchant[:attributes][:name]).to eq("Rings R Us")
    end
  end
end
