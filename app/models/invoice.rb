class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :transactions, dependent: nil

  validates :customer_id, presence: true
  validates :status, presence: true
end
