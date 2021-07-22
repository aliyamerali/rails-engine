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
      200.times do |index|
        Merchant.create!(name: "merchant-#{index+1}")
      end

      get '/api/v1/merchants?per_page=50&page=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:attributes][:name]).to eq("merchant-51")
      expect(merchants.first[:attributes][:name]).to be_a(String)

      get '/api/v1/merchants?per_page=50&page=3'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(50)

      expect(merchants.first).to have_key(:id)
      expect(merchants.first[:attributes][:name]).to eq("merchant-101")
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

      param = "ring"
      get "/api/v1/merchants/find?name=#{param}"

      merchant = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(response).to be_successful

      expect(merchant).to be_a(Hash)
      expect(merchant[:attributes][:name]).to eq("Turing School")
    end

    it 'returns first object in case-sensitive alpha order if multiple matches' do
      create(:merchant, name: "Turing School")
      create(:merchant, name: "Zesty Ringalings")
      create(:merchant, name: "Rings R Us")
      create(:merchant, name: "Hoops Only")

      param = "ring"
      get "/api/v1/merchants/find?name=#{param}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to be_a(Hash)
      expect(merchant[:attributes][:name]).to eq("Rings R Us")
    end

    it 'returns empty response not found if no matches to query' do
      create(:merchant, name: "Hoops Only")
      param = "ring"

      get "/api/v1/merchants/find?name=#{param}"
      output = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response.status).to eq(200)
      expect(output).to be_a(Hash)
      expect(output[:id]).to eq(nil)
    end

    it 'returns 400 if no name given or if param is empty' do
      get "/api/v1/merchants/find"
      expect(response.status).to eq(400)

      get "/api/v1/merchants/find?name="
      expect(response.status).to eq(400)
    end
  end

  describe 'merchants with most sold items' do
    it 'returns x number of merchants ranked by total items sold' do
      customer = create(:customer)
      merchant1 = create(:merchant, name: "Merchant1") # 55
      merchant2 = create(:merchant, name: "Merchant2") # 50
      merchant3 = create(:merchant, name: "Merchant3") # 100
      merchant4 = create(:merchant, name: "Merchant4") # 0

      item1a = create(:item, merchant_id: merchant1.id)
      item1b = create(:item, merchant_id: merchant1.id)
      item1c = create(:item, merchant_id: merchant1.id)
      item2a = create(:item, merchant_id: merchant2.id)
      item2b = create(:item, merchant_id: merchant2.id)
      item3a = create(:item, merchant_id: merchant3.id)

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant3.id, status: "shipped")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice3.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1a.id, invoice_id: invoice1a.id, quantity: 5, unit_price: 5.0)
      InvoiceItem.create!(item_id: item1b.id, invoice_id: invoice1a.id, quantity: 25, unit_price: 5.0)
      InvoiceItem.create!(item_id: item1c.id, invoice_id: invoice1b.id, quantity: 25, unit_price: 5.0)
      InvoiceItem.create!(item_id: item2a.id, invoice_id: invoice2.id, quantity: 20, unit_price: 5.0)
      InvoiceItem.create!(item_id: item2b.id, invoice_id: invoice2.id, quantity: 30, unit_price: 5.0)
      InvoiceItem.create!(item_id: item3a.id, invoice_id: invoice3.id, quantity: 100, unit_price: 5.0)

      get '/api/v1/merchants/most_items?quantity=2'
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(merchants.length).to eq(2)

      expect(merchants.first[:id].to_i).to eq(merchant3.id)
      expect(merchants.first[:attributes][:count]).to eq(100)

      expect(merchants.second[:id].to_i).to eq(merchant1.id)
      expect(merchants.second[:attributes][:count]).to eq(55)
    end
    
    it 'defaults to 5 if no quantity given'
    it 'returns an error if quantity is <= 0' do
      get "/api/v1/merchants/most_items?quantity=-2"

      expect(response.status).to eq(400)
    end
  end

end
