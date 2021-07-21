FactoryBot.define do
  factory :item do
    name { Faker::App.name }
    description { Faker::Lorem.paragraph}
    unit_price {Faker::Number.decimal(l_digits: 2) }
    merchant_id {FactoryBot.create(:merchant).id}
  end
end
