require 'rails_helper'

RSpec.describe 'Revenue API endpoints' do
  describe 'merchant revenue' do
    it 'returns the total revenue for a single merchant' do
      customer = create(:customer)
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      invoice1 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: "shipped") #ONLY INVOICE WITH REVENUE - 125
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: "packaged") #DQ b/c of invoice status
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: "shipped") #DQ b/c of transaction status
      invoice4 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: "shipped") #DQ b/c of transaction status

      invoice1.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice2.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice3.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice4.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item.id, invoice_id: invoice1.id, quantity: 5, unit_price: 5.0)
      InvoiceItem.create!(item_id: item.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.0)
      InvoiceItem.create!(item_id: item.id, invoice_id: invoice2.id, quantity: 20, unit_price: 5.0)
      InvoiceItem.create!(item_id: item.id, invoice_id: invoice3.id, quantity: 30, unit_price: 5.0)
      InvoiceItem.create!(item_id: item.id, invoice_id: invoice4.id, quantity: 10, unit_price: 5.0)

      get "/api/v1/revenue/merchants/#{merchant.id}"

      expect(response).to be_successful
      revenue = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:revenue]

      expect(revenue).to eq(125.0)
    end

    it 'returns 404 if the merchant isn\'t found' do
      get "/api/v1/revenue/merchants/12"

      expect(response.status).to eq(404)
    end
  end

  describe 'merchants with the most revenue' do
    it 'returns a variable no. of merchants ranked by most revenue' do
      customer = create(:customer)
      merchant1 = create(:merchant) # 125
      merchant2 = create(:merchant) # 100
      merchant3 = create(:merchant) # 150
      merchant4 = create(:merchant) # 300
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant2.id)
      item3 = create(:item, merchant_id: merchant3.id)
      item4 = create(:item, merchant_id: merchant4.id)

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant3.id, status: "shipped")
      invoice4a = Invoice.create!(customer_id: customer.id, merchant_id: merchant4.id, status: "shipped")
      invoice4b = Invoice.create!(customer_id: customer.id, merchant_id: merchant4.id, status: "shipped")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice3.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 5, unit_price: 5.0)
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 10, unit_price: 5.0)
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1b.id, quantity: 10, unit_price: 5.0)
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2.id, quantity: 20, unit_price: 5.0)
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice3.id, quantity: 30, unit_price: 5.0)
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice4a.id, quantity: 10, unit_price: 5.0)
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice4b.id, quantity: 10, unit_price: 25.0)

      get "/api/v1/revenue/merchants?quantity=3"
      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.length).to eq(3)
      expect(merchants.first[:id].to_i).to eq(merchant4.id)
      expect(merchants.first[:attributes][:revenue]).to eq(300.0)
      expect(merchants.second[:id].to_i).to eq(merchant3.id)
      expect(merchants.second[:attributes][:revenue]).to eq(150.0)
      expect(merchants.third[:id].to_i).to eq(merchant1.id)
      expect(merchants.third[:attributes][:revenue]).to eq(125.0)
    end

    it 'returns an error if the quantity is missing or invalid' do
      get "/api/v1/revenue/merchants?quantity=0"
      expect(response.status).to eq(400)

      get "/api/v1/revenue/merchants"
      expect(response.status).to eq(400)
    end
  end

  describe 'revenue across data range' do
    #based on invoice create date
    it 'returns total revenue of all merchants between given dates' do
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      merchant3 = create(:merchant)
      merchant4 = create(:merchant)
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant2.id)
      item3 = create(:item, merchant_id: merchant3.id)
      item4 = create(:item, merchant_id: merchant4.id)

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped", created_at: "2021-06-30 14:54:09")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped", created_at: "2021-07-01 14:54:09") #SHOULDN"T BE COUNTED
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped", created_at: "2021-06-01 14:54:09")
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant3.id, status: "shipped", created_at: "2021-05-07 14:54:09") #SHOULDN"T BE COUNTED
      invoice4a = Invoice.create!(customer_id: customer.id, merchant_id: merchant4.id, status: "shipped", created_at: "2021-06-02 14:54:09")
      invoice4b = Invoice.create!(customer_id: customer.id, merchant_id: merchant4.id, status: "shipped", created_at: "2021-06-07 14:54:09")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice3.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 5, unit_price: 5.0) # 25
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 10, unit_price: 5.0) # 50
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1b.id, quantity: 10, unit_price: 5.0) # 50 - OUT OF RANGE
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2.id, quantity: 20, unit_price: 5.0) # 100
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice3.id, quantity: 30, unit_price: 5.0) # 150 - OUT OF RANGE
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice4a.id, quantity: 10, unit_price: 5.0) # 50
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice4b.id, quantity: 10, unit_price: 25.0) # 250

      start_date = '2021-06-01'
      end_date = '2021-06-30'
      get "/api/v1/revenue?start=#{start_date}&end=#{end_date}"

      attributes = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]

      expect(attributes[:revenue]).to eq(475.0)
    end

    it 'returns error if either date ranges are missing' do
      start_date = '2021-06-01'
      end_date = '2021-06-30'

      get "/api/v1/revenue?start=#{start_date}"
      expect(response.status).to eq(400)

      get "/api/v1/revenue?end=#{end_date}"
      expect(response.status).to eq(400)
    end

    it 'returns error if both date ranges are missing' do
      get "/api/v1/revenue"
      expect(response.status).to eq(400)

      get "/api/v1/revenue?start=&end="
      expect(response.status).to eq(400)
    end
  end

  describe 'items ranked by revenue' do
    it 'returns x number of items ranked by most revenue' do
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, name: "item1", merchant_id: merchant1.id) # 0
      item2 = create(:item, name: "item2", merchant_id: merchant1.id) # 30
      item3 = create(:item, name: "item3", merchant_id: merchant1.id) # 35
      item4 = create(:item, name: "item4", merchant_id: merchant1.id) # 40
      item5 = create(:item, name: "item5", merchant_id: merchant1.id) # 0
      item6 = create(:item, name: "item6", merchant_id: merchant2.id) # 25
      item7 = create(:item, name: "item7", merchant_id: merchant2.id) # 250
      item8 = create(:item, name: "item8", merchant_id: merchant2.id) # 75
      item9 = create(:item, name: "item9", merchant_id: merchant2.id) # 150
      item10 = create(:item, name: "item10", merchant_id: merchant2.id) # 0

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1c = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "packaged")
      invoice2a = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice2b = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice2c = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "packaged")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice2b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 5, unit_price: 5.0) # 25 - DQ
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice1b.id, quantity: 6, unit_price: 5.0) # 30
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice1b.id, quantity: 7, unit_price: 5.0) # 35
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice1b.id, quantity: 8, unit_price: 5.0) # 40
      InvoiceItem.create!(item_id: item5.id, invoice_id: invoice1c.id, quantity: 30, unit_price: 5.0) # 150 - DQ
      InvoiceItem.create!(item_id: item6.id, invoice_id: invoice2a.id, quantity: 5, unit_price: 5.0) # 25
      InvoiceItem.create!(item_id: item7.id, invoice_id: invoice2b.id, quantity: 10, unit_price: 25.0) # 250
      InvoiceItem.create!(item_id: item8.id, invoice_id: invoice2b.id, quantity: 3, unit_price: 25.0) # 75
      InvoiceItem.create!(item_id: item9.id, invoice_id: invoice2b.id, quantity: 6, unit_price: 25.0) # 150
      InvoiceItem.create!(item_id: item10.id, invoice_id: invoice2c.id, quantity: 10, unit_price: 25.0) # 250 - DQ

      get "/api/v1/revenue/items?quantity=4"

      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(items.length).to eq(4)

      expect(items.first[:id].to_i).to eq(item7.id)
      expect(items.first[:attributes][:revenue]).to eq(250.0)

      expect(items.second[:id].to_i).to eq(item9.id)
      expect(items.second[:attributes][:revenue]).to eq(150.0)

      expect(items.third[:id].to_i).to eq(item8.id)
      expect(items.third[:attributes][:revenue]).to eq(75.0)

      expect(items.last[:id].to_i).to eq(item4.id)
      expect(items.last[:attributes][:revenue]).to eq(40.0)
    end

    it 'returns 10 items if no limit given' do
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, name: "item1", merchant_id: merchant1.id) # 20
      item2 = create(:item, name: "item2", merchant_id: merchant1.id) # 30
      item3 = create(:item, name: "item3", merchant_id: merchant1.id) # 35
      item4 = create(:item, name: "item4", merchant_id: merchant1.id) # 40
      item5 = create(:item, name: "item5", merchant_id: merchant1.id) # 150
      item6 = create(:item, name: "item6", merchant_id: merchant2.id) # 25
      item7 = create(:item, name: "item7", merchant_id: merchant2.id) # 250
      item8 = create(:item, name: "item8", merchant_id: merchant2.id) # 75
      item9 = create(:item, name: "item9", merchant_id: merchant2.id) # 144
      item10 = create(:item, name: "item10", merchant_id: merchant2.id) # 300

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice1c = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice2a = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice2b = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")
      invoice2c = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 4, unit_price: 5.0) # 20
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice1b.id, quantity: 6, unit_price: 5.0) # 30
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice1b.id, quantity: 7, unit_price: 5.0) # 35
      InvoiceItem.create!(item_id: item4.id, invoice_id: invoice1b.id, quantity: 8, unit_price: 5.0) # 40
      InvoiceItem.create!(item_id: item5.id, invoice_id: invoice1c.id, quantity: 30, unit_price: 5.0) # 150
      InvoiceItem.create!(item_id: item6.id, invoice_id: invoice2a.id, quantity: 5, unit_price: 5.0) # 25
      InvoiceItem.create!(item_id: item7.id, invoice_id: invoice2b.id, quantity: 10, unit_price: 25.0) # 250
      InvoiceItem.create!(item_id: item8.id, invoice_id: invoice2b.id, quantity: 3, unit_price: 25.0) # 75
      InvoiceItem.create!(item_id: item9.id, invoice_id: invoice2b.id, quantity: 6, unit_price: 24.0) # 144
      InvoiceItem.create!(item_id: item10.id, invoice_id: invoice2c.id, quantity: 10, unit_price: 30.0) # 300

      get "/api/v1/revenue/items"

      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(items.length).to eq(10)

      expect(items[0][:id].to_i).to eq(item10.id)
      expect(items[0][:attributes][:revenue]).to eq(300.0)

      expect(items[1][:id].to_i).to eq(item7.id)
      expect(items[1][:attributes][:revenue]).to eq(250.0)

      expect(items[2][:id].to_i).to eq(item5.id)
      expect(items[2][:attributes][:revenue]).to eq(150.0)

      expect(items[3][:id].to_i).to eq(item9.id)
      expect(items[3][:attributes][:revenue]).to eq(144.0)

      expect(items[4][:id].to_i).to eq(item8.id)
      expect(items[4][:attributes][:revenue]).to eq(75.0)

      expect(items[5][:id].to_i).to eq(item4.id)
      expect(items[5][:attributes][:revenue]).to eq(40.0)

      expect(items[6][:id].to_i).to eq(item3.id)
      expect(items[6][:attributes][:revenue]).to eq(35.0)

      expect(items[7][:id].to_i).to eq(item2.id)
      expect(items[7][:attributes][:revenue]).to eq(30.0)

      expect(items[8][:id].to_i).to eq(item6.id)
      expect(items[8][:attributes][:revenue]).to eq(25.0)

      expect(items[9][:id].to_i).to eq(item1.id)
      expect(items[9][:attributes][:revenue]).to eq(20.0)
    end

    it 'returns an error if limit given is negative' do
      get "/api/v1/revenue/items?quantity=-2"

      expect(response.status).to eq(400)
    end
  end

  describe 'potential revenue of unshipped orders' do
    it 'returns x invoices by potential revenue of unshipped items' do
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, name: "item1", merchant_id: merchant1.id)
      item2 = create(:item, name: "item2", merchant_id: merchant1.id)
      item3 = create(:item, name: "item3", merchant_id: merchant1.id)

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "packaged")
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "packaged")
      invoice1c = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped")
      invoice2a = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "packaged")
      invoice2b = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "packaged")
      invoice2c = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "packaged")

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice2b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2c.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 5, unit_price: 5.0) # 25 - DQ
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1b.id, quantity: 6, unit_price: 5.0) # 30
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice1b.id, quantity: 7, unit_price: 5.0) # 35
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice1b.id, quantity: 8, unit_price: 5.0) # 40
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1c.id, quantity: 30, unit_price: 5.0) # 150 - DQ
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2a.id, quantity: 5, unit_price: 5.0) # 25
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice2b.id, quantity: 10, unit_price: 25.0) # 250
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2b.id, quantity: 3, unit_price: 25.0) # 75
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2c.id, quantity: 6, unit_price: 25.0) # 150
      InvoiceItem.create!(item_id: item3.id, invoice_id: invoice2c.id, quantity: 10, unit_price: 25.0) # 250

      get "/api/v1/revenue/unshipped?quantity=3"
      invoices = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful

      expect(invoices.first[:id].to_i).to eq(invoice2c.id)
      expect(invoices.first[:attributes][:potential_revenue]).to eq(400.0)

      expect(invoices.second[:id].to_i).to eq(invoice2b.id)
      expect(invoices.second[:attributes][:potential_revenue]).to eq(325.0)

      expect(invoices.third[:id].to_i).to eq(invoice1b.id)
      expect(invoices.third[:attributes][:potential_revenue]).to eq(105.0)
    end

    it 'returns an error if quantity is left blank' do
      get "/api/v1/revenue/unshipped"

      expect(response.status).to eq(400)
    end

    it 'returns an error if quantity is <= 0' do
      get "/api/v1/revenue/unshipped?quantity=-2"

      expect(response.status).to eq(400)
    end
  end

  describe 'weekly revenue' do
    it 'returns the total revenue by week' do
      
    end
  end
end
