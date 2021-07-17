class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices

  def self.paginate(per_page, page)
    limit(per_page)
    .offset(per_page * (page-1))
  end
end
