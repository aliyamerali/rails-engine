require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'class methods' do
    it '.revenue_in_date_range returns total revenue in a date range' do
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

      expect(Invoice.revenue_in_date_range(start_date, end_date)).to eq(475.0)
    end

    it '.unshipped_potential_revenue returns top x invoices by potential revenue of unshipped orders' do
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

      invoices = Invoice.unshipped_potential_revenue(3)

      expect(invoices.first.id).to eq(invoice2c.id)
      expect(invoices.first.potential_revenue).to eq(400.0)

      expect(invoices.second.id).to eq(invoice2b.id)
      expect(invoices.second.potential_revenue).to eq(325.0)

      expect(invoices.third.id).to eq(invoice1b.id)
      expect(invoices.third.potential_revenue).to eq(105.0)
    end

    it '.revenue_by_week returns weekly revenue across all merchants' do
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant2.id)

      invoice1a = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped", created_at: "2021-06-30 14:54:09") #W4
      invoice1b = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped", created_at: "2021-07-01 14:54:09") #W4
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant1.id, status: "shipped", created_at: "2021-06-01 14:54:09") #W2
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped", created_at: "2021-05-07 14:54:09")  #W1
      invoice4a = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped", created_at: "2021-06-02 14:54:09") #w2
      invoice4b = Invoice.create!(customer_id: customer.id, merchant_id: merchant2.id, status: "shipped", created_at: "2021-06-07 14:54:09") #W3

      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice1a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "failure")
      invoice1b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice2.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice3.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4a.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")
      invoice4b.transactions.create!(credit_card_number: "92839", credit_card_expiration_date: "", result: "success")

      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 8, unit_price: 5.0) # 40
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1a.id, quantity: 10, unit_price: 5.0) # 50
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice1b.id, quantity: 10, unit_price: 5.0) # 50
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice2.id, quantity: 20, unit_price: 5.0) # 100
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice3.id, quantity: 30, unit_price: 5.0) # 150
      InvoiceItem.create!(item_id: item1.id, invoice_id: invoice4a.id, quantity: 5, unit_price: 5.0) # 25
      InvoiceItem.create!(item_id: item2.id, invoice_id: invoice4b.id, quantity: 10, unit_price: 25.0) # 250

      weekly_revenue = Invoice.revenue_by_week

      expect(weekly_revenue.length).to eq(4)

      expect(weekly_revenue.first.week).to eq("2021-05-03")
      expect(weekly_revenue.first.revenue).to eq(150)

      expect(weekly_revenue.second.week).to eq("2021-05-31")
      expect(weekly_revenue.second.revenue).to eq(125)

      expect(weekly_revenue.third.week).to eq("2021-06-07")
      expect(weekly_revenue.third.revenue).to eq(250)

      expect(weekly_revenue.fourth.week).to eq("2021-06-28")
      expect(weekly_revenue.fourth.revenue).to eq(140)
    end
  end
end
