require 'ffaker'

FactoryGirl.define do
  factory :type do
    name
    description Faker::Lorem.sentences
    count 0
  end

end
