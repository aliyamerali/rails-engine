class Customer < ApplicationRecord
  has_many :invoices, dependent: nil
end
