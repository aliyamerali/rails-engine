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
  end
end
