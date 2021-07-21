class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices, dependent: nil

  def self.search_by_name(query)
    Merchant.where('name ILIKE ?', "%#{query}%")
            .order(name: :asc)
            .first
  end

  def self.most_revenue(limit)
    joins(invoices: [:transactions, :invoice_items])
    .select('merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue')
    .where(transactions: { result: 'success' })
    .where(invoices: { status: 'shipped' })
    .group(:id)
    .order('revenue DESC')
    .limit(limit)
  end

  def revenue
    invoices
      .joins(:transactions, :invoice_items)
      .where(transactions: { result: 'success' })
      .where(invoices: { status: 'shipped' })
      .sum('invoice_items.unit_price * invoice_items.quantity')
  end
end
