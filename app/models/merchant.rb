class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices, dependent: nil

  def self.search_by_name(query)
    Merchant.where('name ILIKE ?', "%#{query}%")
            .order(name: :asc)
            .first
  end

  def revenue
    invoices
    .joins(:transactions, :invoice_items)
    .where(transactions: {result: "success"})
    .where(invoices: {status: "shipped"})
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end
end
