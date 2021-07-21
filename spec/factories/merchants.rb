FactoryBot.define do
  factory :merchant do
    name { Faker::App.name }

    # trait :with_invoices do
    #   after(:create) do |merchant|
    #     create(
    #       :appointment,
    #       customer: account.customer,
    #       starts_at: Time.zone.now + 1.day
    #     )
    #   end
    # end


  end
end
