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
  end
end
