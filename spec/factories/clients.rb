require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :client do
    categories {
      tmp = Category::CATEGORIES.sample(2)
      [ Category.new(name: tmp[0]), Category.new(name: tmp[1]) ]
    }
    locations           { (1..5).map { FactoryGirl.build(:location) }}
    username            { "#{SecureRandom.base64(4)}#{FFaker::Internet.user_name}".downcase }
    email               { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password            'qwertyqwerty'
    name                { "#{FFaker::Company.name}#{SecureRandom.base64(4)}" }
    rate                0.0
    image_url           { FFaker::Internet.http_url }
    addresses           { (1..5).map { FFaker::Address.street_address }}

    factory :client_with_discounts do
      discounts { (1..5).map { FactoryGirl.build(:discount) }}
    end
    factory :client_with_plan do
      client_plans {
        plan = Plan.all.sample
        [plan.to_client_plan]
      }
    end
    factory :client_with_expired_plan do
      client_plans {
        plan = Plan.all.sample
        plan = plan.to_client_plan
        plan.expired_date = DateTime.now - 1.minute
        [plan]
      }
    end
  end

end
