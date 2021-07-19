class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true

  def self.find_all(name = nil, min_price = nil, max_price = nil)
    if name.nil?
      min_price = 0 if min_price.nil?
      max_price = Item.maximum(:unit_price) if max_price.nil?
      Item.where('unit_price >= ? AND unit_price <= ?', min_price, max_price)
    else
      Item.where('name ILIKE ?', "%#{name}%").order(name: :asc)
    end
  end
end
