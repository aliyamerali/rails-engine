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
      items_pg2 = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(items_pg2.count).to eq(50)

      expect(items_pg2.first).to have_key(:id)
      expect(items_pg2.first[:id].to_i).to_not eq(Item.first.id)

      expect(items_pg2.first[:attributes]).to have_key(:name)
      expect(items_pg2.first[:attributes][:name]).to be_a(String)

      expect(items_pg2.first[:attributes]).to have_key(:description)
      expect(items_pg2.first[:attributes][:description]).to be_a(String)

      expect(items_pg2.first[:attributes]).to have_key(:unit_price)
      expect(items_pg2.first[:attributes][:unit_price]).to be_a(Float)

      expect(items_pg2.first[:attributes]).to have_key(:merchant_id)
      expect(items_pg2.first[:attributes][:merchant_id]).to be_a(Integer)

      get '/api/v1/items?per_page=50&page=3'

      expect(response).to be_successful
      items_pg3 = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items_pg3.count).to eq(50)
      expect(items_pg3.first[:id].to_i).to_not eq(items_pg2.first[:id].to_i)
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

    it 'returns all items if per_page is really big' do
      create_list(:item, 243)

      get '/api/v1/items?per_page=25000'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(243)
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

  describe 'update an item' do
    it 'updates an item if in record and valid attributes' do
      merchant = create(:merchant)
      item = create(:item)
      previous_name = item.name
      item_params = ({
                "name": "value1",
                "merchant_id": merchant.id
              })
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})

      post_item = Item.find(item.id)

      expect(response).to be_successful
      expect(post_item.name).to_not eq(previous_name)
      expect(post_item.name).to eq("value1")
    end

    it 'returns 404 if merchant id invalid' do
      item = create(:item)
      item_params = ({
                "name": "value1",
                "merchant_id": 98123
              })
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})

      expect(response.status).to eq(404)
    end

    it 'returns not found if item doesn\'t already exist' do
      item_params = ({
                "name": "value1"
              })
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/143254", headers: headers, params: JSON.generate({item: item_params})

      expect(response.status).to eq(404)
    end
  end

  describe 'destroy an item' do
    it 'destroys an item when it exists' do
      item = create(:item)

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(response).to be_successful
      expect(Item.count).to eq(0)
      expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns an error if the item does not exist' do
      delete '/api/v1/items/500'

      expect(response.status).to eq(404)
    end

    #TODO: Test for destroy any invoice if this was the only item on an invoice
  end
end
