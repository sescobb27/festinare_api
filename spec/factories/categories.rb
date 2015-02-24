require 'ffaker'

FactoryGirl.define do
  factory :category do
    name        { %w(Bar Disco Restaurant).sample }
    description Faker::Lorem.sentences
    count 0
  end

end
