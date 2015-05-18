require 'ffaker'

FactoryGirl.define do
  factory :category do
    name        { Category::CATEGORIES.sample }
    description FFaker::Lorem.sentences
  end
end
