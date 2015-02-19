require 'ffaker'

FactoryGirl.define do
  factory :category do
    name        Faker::Lorem.sentences 1
    description Faker::Lorem.sentences
    count 0
  end

end
