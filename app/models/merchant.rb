class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices, dependent: nil

  def self.search_by_name(query)
    Merchant.where('name ILIKE ?', "%#{query}%")
            .order(name: :asc)
            .first
  end
end
