FactoryBot.define do
  factory :customer do
    first_name { Faker::App.name }
    last_name { Faker::App.name }
  end
end
