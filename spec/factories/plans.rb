require 'ffaker'

FactoryGirl.define do
  factory :plan do
    name              Faker::Name.name
    description       Faker::Lorem.sentences
    status            true
    price             { rand(500_000) }
    num_of_discounts  { rand(100) }
  end

end
