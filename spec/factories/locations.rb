require 'ffaker'

FactoryGirl.define do
  factory :location do
    latitude  Faker::Geolocation.lat
    longitude Faker::Geolocation.lng
  end
end
