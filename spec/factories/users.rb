require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :user do
    username  { "#{FFaker::Internet.user_name}#{SecureRandom.base64(4)}".downcase }
    name      { FFaker::Name.name }
    lastname  { FFaker::Name.last_name }
    email     { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password  'qwertyqwerty'

    factory :user_with_subscriptions do
      categories {
        tmp = Category::CATEGORIES.sample(2)
        [
          Category.new(name: tmp[0]),
          Category.new(name: tmp[1])
        ]
      }
    end

    factory :user_with_mobile do
      categories {
        tmp = Category::CATEGORIES.sample(2)
        [
          Category.new(name: tmp[0]),
          Category.new(name: tmp[1])
        ]
      }
      mobile { FactoryGirl.build(:mobile) }
    end
  end
end
