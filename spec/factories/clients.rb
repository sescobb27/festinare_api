require 'ffaker'

FactoryGirl.define do
  factory :client do
    after(:build)       { |client| client.categories.concat(Category.all.to_a) }
    locations           { (1..5).map { FactoryGirl.build(:location) }}
    username            { Faker::Internet.user_name }
    email               { Faker::Internet.email }
    password            'qwertyqwerty'
    name                Faker::Company.name
    rate                0.0
    image_url           Faker::Internet.http_url
    addresses           { (1..5).map { Faker::Address.street_address }}

    factory :user_with_discounts do
      discounts { (1..5).map { FactoryGirl.build(:discount) }}
    end
    factory :client_with_plans do
      plans { (1..5).map { FactoryGirl.create(:plan) }}
    end
  end

end
