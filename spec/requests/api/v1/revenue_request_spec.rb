require 'rails_helper'

# HINT: Invoices must have a successful transaction and be
# shipped to the customer to be considered as revenue.

RSpec.describe 'Revenue API endpoints' do
  describe 'merchant revenue' do
    xit 'returns the total revenue for a single merchant' do
      merchant = create(:merchant)
      item = create(:item, merchant_id = merchant.id)
      create_list(:invoice, merchant_id = merchant.id, item_id = item.id, status = 'shipped', 20)
      create_list(:invoice, merchant_id = merchant.id, item_id = item.id, status = 'packaged', 20)


    end
  end
end
