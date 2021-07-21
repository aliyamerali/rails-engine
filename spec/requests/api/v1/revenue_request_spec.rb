require 'rails_helper'

# HINT: Invoices must have a successful transaction and be
# shipped to the customer to be considered as revenue.

RSpec.describe 'Revenue API endpoints' do
  describe 'merchant revenue' do
    it 'returns the total revenue for a single merchant' do
      customer = create(:customer)
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      # create(:invoice, customer_id: customer.id, merchant_id: merchant.id, status: 'shipped') do |invoice|
      #   create_list(:invoice_item, 5, item_id: item.id)
      #   create_list(:transaction, 5)
      # end
      #
      # create(:invoice, merchant_id: merchant.id, customer_id: customer.id, status: 'packaged') do |invoice|
      #   create_list(:invoice_item, 5, item_id: item.id)
      #   create_list(:transaction, 5)
      # end

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
end
