require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :user do
    username  { "#{Faker::Internet.user_name}#{SecureRandom.base64(4)}" }
    name      { Faker::Name.name }
    lastname  { Faker::Name.last_name }
    email     { "#{SecureRandom.base64(4)}#{Faker::Internet.email}" }
    password  'qwertyqwerty'

    factory :user_with_subscriptions do
      categories { (1..2).map { FactoryGirl.build(:category) }}
    end

    factory :user_with_mobile do
      mobile { FactoryGirl.build(:mobile) }
    end
  end
end
