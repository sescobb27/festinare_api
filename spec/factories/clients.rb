require 'ffaker'

FactoryGirl.define do
  factory :client do
    after(:build)       { |client| client.categories.concat(Category.all.to_a) }
    locations           { (1..5).map { FactoryGirl.build(:location) }}
    discounts           { (1..5).map { FactoryGirl.build(:discount) }}
    plans               { (1..5).map { FactoryGirl.create(:plan) }}
    username            { Faker::Internet.user_name }
    email               { Faker::Internet.email }
    encrypted_password  'qwertyqwerty'
    name                Faker::Company.name
    created_at          Time.now
    rate                0.0
    image_url           Faker::Internet.http_url
    addresses           {(1..5).map { Faker::Address.street_address }}

  end

end
