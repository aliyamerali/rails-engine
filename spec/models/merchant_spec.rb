require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:invoices) }
    it { should have_many(:items).dependent(:destroy) }
  end

  describe 'class methods' do
    it '.pagination returns results for a given page with given per page rate' do
      create_list(:merchant, 50)

      merchants = Merchant.all

      expect(merchants.paginate(10,2).first.id).to eq(Merchant.first.id + 10)
      expect(merchants.paginate(20,1).first.id).to eq(Merchant.first.id)
      expect(merchants.paginate(15,4).first.id).to eq(Merchant.first.id + 45)
    end

    describe '.search_by_name(query)' do
      it 'returns a single record of a merchant' do
        turing = create(:merchant, name: "Turing School")
        hoops = create(:merchant, name: "Hoops Only")
        query = "ring"

        expect(Merchant.search_by_name(query)).to eq(turing)
      end

      it 'returns first object in case-sensitive alpha order if multiple matches' do
        turing = create(:merchant, name: "Turing School")
        zest = create(:merchant, name: "Zesty Ringalings")
        rings = create(:merchant, name: "Rings R Us")
        hoops = create(:merchant, name: "Hoops Only")
        query = "ring"

        expect(Merchant.search_by_name(query)).to eq(rings)
      end

      it 'returns nil if no match found' do |variable|
        turing = create(:merchant, name: "Turing School")
        zest = create(:merchant, name: "Zesty Ringalings")
        rings = create(:merchant, name: "Rings R Us")
        hoops = create(:merchant, name: "Hoops Only")
        query = "dogs"

        expect(Merchant.search_by_name(query)).to eq(nil)
      end
    end
  end

  describe 'instance methods' do
    it '#total_revenue returns the total revenue for the merchant' do
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

      expect(merchant.revenue).to eq(125.0)
    end
  end
end
