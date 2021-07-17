class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices

  def self.paginate(per_page, page)
    page = 1 if page <= 0
    limit(per_page)
    .offset(per_page * (page-1))
  end
end
