require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :customer do
    username  do
      "#{FFaker::Internet.user_name}#{SecureRandom.base64(4)}".downcase
    end
    fullname { FFaker::Name.name + FFaker::Name.last_name }
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
    client_ids []
    token { [SecureRandom.base64] }
    reviews []

    factory :customer_with_subscriptions do
      categories do
        tmp = Category::CATEGORIES.sample(2)
        [
          Category.new(name: tmp[0]),
          Category.new(name: tmp[1])
        ]
      end
    end

    factory :customer_with_mobile do
      categories do
        tmp = Category::CATEGORIES.sample(2)
        [
          Category.new(name: tmp[0]),
          Category.new(name: tmp[1])
        ]
      end
      mobile { FactoryGirl.build(:mobile) }
    end
  end
end
