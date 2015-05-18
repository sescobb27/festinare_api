require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :client do
    categories do
      tmp = Category::CATEGORIES.sample(2)
      [Category.new(name: tmp[0]), Category.new(name: tmp[1])]
    end
    locations           { (1..5).map { FactoryGirl.build(:location) } }
    username do
      "#{SecureRandom.base64(4)}#{FFaker::Internet.user_name}".downcase
    end
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
    name { "#{FFaker::Company.name}#{SecureRandom.base64(4)}" }
    rates []
    image_url { FFaker::Internet.http_url }
    addresses { (1..5).map { FFaker::Address.street_address } }
    token { [SecureRandom.base64] }

    factory :client_with_discounts do
      discounts { (1..5).map { FactoryGirl.build(:discount) } }
    end
    factory :client_with_plan do
      client_plans do
        plan = Plan.all.sample
        [plan.to_client_plan]
      end
    end
    factory :client_with_expired_plan do
      client_plans do
        plan = Plan.all.sample
        plan = plan.to_client_plan
        plan.expired_date = Time.zone.now - 1.minute
        [plan]
      end
    end
  end
end
