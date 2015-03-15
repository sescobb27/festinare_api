require 'ffaker'

FactoryGirl.define do
  factory :category do
    name        { Category::CATEGORIES.sample }
    description Faker::Lorem.sentences
    count 0
  end

end
