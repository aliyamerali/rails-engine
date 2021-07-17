require 'rails_helper'

RSpec.describe 'Items API' do
  describe 'index' do
    it 'returns a list of all items with a default of 20 max and page 1' do
      create_list(:item, 50)

      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(20)

      expect(items.first).to have_key(:id)
      expect(items.first[:id].to_i).to eq(Item.first.id)

      expect(items.first[:attributes]).to have_key(:name)
      expect(items.first[:attributes][:name]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:description)
      expect(items.first[:attributes][:description]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:unit_price)
      expect(items.first[:attributes][:unit_price]).to be_a(Float)

      expect(items.first[:attributes]).to have_key(:merchant_id)
      expect(items.first[:attributes][:merchant_id]).to be_a(Integer)
    end

    it 'takes query params for per page and page, returing accurate data' do
      create_list(:item, 200)

      get '/api/v1/items?per_page=50&page=2'
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(items.count).to eq(50)

      expect(items.first).to have_key(:id)
      expect(items.first[:id].to_i).to_not eq(Item.first.id)

      expect(items.first[:attributes]).to have_key(:name)
      expect(items.first[:attributes][:name]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:description)
      expect(items.first[:attributes][:description]).to be_a(String)

      expect(items.first[:attributes]).to have_key(:unit_price)
      expect(items.first[:attributes][:unit_price]).to be_a(Float)

      expect(items.first[:attributes]).to have_key(:merchant_id)
      expect(items.first[:attributes][:merchant_id]).to be_a(Integer)

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

  describe 'show - fetch a single record' do
    it 'returns the record requested if it exists' do
      create(:item)
      item = Item.first

      get "/api/v1/items/#{item.id}"
      output = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful

      expect(output).to have_key(:id)
      expect(output[:id].to_i).to eq(item.id)

      expect(output[:attributes]).to have_key(:name)
      expect(output[:attributes][:name]).to be_a(String)

      expect(output[:attributes]).to have_key(:description)
      expect(output[:attributes][:description]).to be_a(String)

      expect(output[:attributes]).to have_key(:unit_price)
      expect(output[:attributes][:unit_price]).to be_a(Float)

      expect(output[:attributes]).to have_key(:merchant_id)
      expect(output[:attributes][:merchant_id]).to be_a(Integer)
    end

    it 'returns 404 if no record exists' do
      get '/api/v1/items/12'

      expect(response.status).to eq(404)
    end
  end

  describe 'create a new item' do
    it 'creates a new item and renders a json record of the new item when all attributes present' do
      merchant = create(:merchant)
      item_params = ({
                "name": "value1",
                "description": "value2",
                "unit_price": 100.99,
                "merchant_id": merchant.id.to_i
              })
      headers = {"CONTENT_TYPE" => "application/json"}

      post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last
      output = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(output[:attributes][:name]).to eq(item_params[:name])
      expect(created_item.name).to eq(item_params[:name])

      expect(output[:attributes][:description]).to eq(item_params[:description])
      expect(created_item.description).to eq(item_params[:description])

      expect(output[:attributes][:unit_price]).to eq(item_params[:unit_price])
      expect(created_item.unit_price).to eq(item_params[:unit_price])

      expect(output[:attributes][:merchant_id]).to eq(item_params[:merchant_id])
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
    end

    it 'returns an error if any attributes are missing' do
      merchant = create(:merchant)
      item_params = ({
                "name": "value1",
                "description": "value2",
                "merchant_id": merchant.id.to_i
              })
      headers = {"CONTENT_TYPE" => "application/json"}

      post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)
      expect(response.status).to eq(400)
    end
  end
end
