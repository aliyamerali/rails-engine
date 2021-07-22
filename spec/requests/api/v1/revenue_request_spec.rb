require 'rails_helper'

# HINT: Invoices must have a successful transaction and be
# shipped to the customer to be considered as revenue.

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
  end
end
