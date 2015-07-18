require 'ffaker'

FactoryGirl.define do
  factory :location do
    latitude FFaker::Geolocation.lat
    longitude FFaker::Geolocation.lng
  end
end
