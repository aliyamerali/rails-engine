# FILE ONLY NEEDED if used for revenue setup

FactoryBot.define do
  factory :customer do
    first_name { Faker::App.name }
    last_name { Faker::App.name }
  end

  factory :invoice do
    customer_id {create(:customer).id}
    merchant_id {create(:merchant).id}
    status { ["packaged", "shipped", "returned"].sample }
  end

  factory :transaction do
    invoice_id {create(:invoice).id}
    credit_card_number { Faker::Finance.credit_card}
    credit_card_expiration_date {Faker::Date.forward(days: 23)}
    result { ["success", "failed", "refunded"].sample }
  end

  factory :invoice_item do
    item_id {create(:item).id}
    invoice_id {create(:invoice).id}
    quantity {Faker::Number.number(digits: 3)}
    unit_price {Faker::Number.decimal(l_digits: 2) }
  end
end
