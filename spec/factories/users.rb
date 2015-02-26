require 'ffaker'

FactoryGirl.define do
  factory :user do
    username  { Faker::Internet.user_name }
    name      { Faker::Name.name }
    lastname  { Faker::Name.last_name }
    email     { Faker::Internet.email }
    password  'qwertyqwerty'

    factory :user_with_subscriptions do
      categories { (1..2).map { FactoryGirl.build(:category) }}
    end
  end
end

