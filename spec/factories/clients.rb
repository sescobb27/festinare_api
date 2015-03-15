require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :client do
    after(:build)       { |client| client.categories.concat( (1..2).map { FactoryGirl.build(:category) }) }
    locations           { (1..5).map { FactoryGirl.build(:location) }}
    username            { "#{SecureRandom.base64(4)}#{Faker::Internet.user_name}".downcase }
    email               { "#{SecureRandom.base64(4)}#{Faker::Internet.email}".downcase }
    password            'qwertyqwerty'
    name                { "#{Faker::Company.name}#{SecureRandom.base64(4)}" }
    rate                0.0
    image_url           { Faker::Internet.http_url }
    addresses           { (1..5).map { Faker::Address.street_address }}

    factory :client_with_discounts do
      discounts { (1..5).map { FactoryGirl.build(:discount) }}
    end
    factory :client_with_plan do
      client_plans {
        plan = Plan.all.sample
        [plan.to_client_plan]
      }
    end
  end

end
