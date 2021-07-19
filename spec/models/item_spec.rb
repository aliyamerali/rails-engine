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
  end
end
