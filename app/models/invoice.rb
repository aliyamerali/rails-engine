class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :transactions, dependent: nil

  validates :customer_id, presence: true
  validates :status, presence: true

  def self.revenue_in_date_range(start_date, end_date)
    start_datetime = DateTime.parse(start_date).beginning_of_day
    end_datetime = DateTime.parse(end_date).end_of_day

    joins(:transactions, :invoice_items)
      .where(transactions: { result: 'success' })
      .where(invoices: { status: 'shipped' })
      .where(created_at: start_datetime..end_datetime)
      .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def self.unshipped_potential_revenue(limit)
    joins(:transactions, :invoice_items)
      .select('invoices.id, SUM(invoice_items.unit_price * invoice_items.quantity) AS potential_revenue')
      .where(transactions: { result: 'success' })
      .where(invoices: { status: 'packaged' })
      .group(:id)
      .order('potential_revenue DESC')
      .limit(limit)
  end

  def self.revenue_by_week
    joins(:transactions, :invoice_items)
      .select("DATE_TRUNC('week', invoices.created_at) as week,
              SUM(invoice_items.unit_price * invoice_items.quantity) as revenue")
      .where(transactions: { result: 'success' })
      .where(invoices: { status: 'shipped' })
      .group('week')
      .order('week')
  end
end
