require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should belong_to(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
  end

  describe 'class methods' do
    it '.pagination returns results for a given page with given per page rate' do
      create_list(:item, 50)

      items = Item.all

      expect(items.paginate(10,2).first.id).to eq(Item.first.id + 10)
      expect(items.paginate(20,1).first.id).to eq(Item.first.id)
      expect(items.paginate(15,4).first.id).to eq(Item.first.id + 45)
    end

    describe '.find_all' do
      it 'searches items by name' do
        create(:item, name: "Alpha ring")
        create(:item, name: "beta ring")
        create(:item, name: "Beta thing")
        create(:item, name: "Gamma ring")

        name = "ring"
        items = Item.find_all(name)

        expect(items.count).to eq(3)
        expect(items.first.name).to eq("Alpha ring")
        expect(items.second.name).to eq("Gamma ring")
        expect(items.last.name).to eq("beta ring")
      end

      it 'returns an empty array if no matches' do
        create(:item, name: "Beta thing")

        name = "ring"
        items = Item.find_all(name)

        expect(items.count).to eq(0)
      end

      it 'can take search param for min_price OR max_price' do
        create(:item, unit_price: 10.99)
        create(:item, unit_price: 3.99)
        create(:item, unit_price: 9.99)

        min = 5
        items = Item.find_all(nil, min)

        expect(items.count).to eq(2)
        expect(items.first.unit_price).to eq(10.99)
        expect(items.last.unit_price).to eq(9.99)

        max = 5
        items = Item.find_all(nil, nil, max)

        expect(items.count).to eq(1)
        expect(items.first.unit_price).to eq(3.99)
      end

      it 'can take search param for min_price AND max_price' do
        create(:item, unit_price: 10.99)
        create(:item, unit_price: 3.99)
        create(:item, unit_price: 5.99)
        create(:item, unit_price: 9.99)

        min = 5
        max = 10
        items = Item.find_all(nil, min, max)

        expect(items.count).to eq(2)
        expect(items.first.unit_price).to eq(5.99)
        expect(items.last.unit_price).to eq(9.99)
      end
    end

    it '.most_revenue(limit) returns given number of items ranked by total revenue' do
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

      items = Item.most_revenue(4)

      expect(items.length).to eq(4)

      expect(items.first.id).to eq(item7.id)
      expect(items.first.revenue).to eq(250.0)

      expect(items.second.id).to eq(item9.id)
      expect(items.second.revenue).to eq(150.0)

      expect(items.third.id).to eq(item8.id)
      expect(items.third.revenue).to eq(75.0)

      expect(items.last.id).to eq(item4.id)
      expect(items.last.revenue).to eq(40.0)
    end
  end
end
