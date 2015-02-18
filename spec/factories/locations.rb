require 'ffaker'

FactoryGirl.define do
  factory :location do
    latitude rand
    longitude rand
  end
end
