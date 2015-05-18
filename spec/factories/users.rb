require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :user do
    username  do
      "#{FFaker::Internet.user_name}#{SecureRandom.base64(4)}".downcase
    end
    name { FFaker::Name.name }
    lastname { FFaker::Name.last_name }
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
    client_ids []

    factory :user_with_subscriptions do
      categories do
        tmp = Category::CATEGORIES.sample(2)
        [
          Category.new(name: tmp[0]),
          Category.new(name: tmp[1])
        ]
      end
    end

    factory :user_with_mobile do
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
