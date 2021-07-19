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
end
