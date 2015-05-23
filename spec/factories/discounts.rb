require 'ffaker'

FactoryGirl.define do
  factory :discount do
    after(:build) do |discount|
      discount.categories.concat((1..2).map { FactoryGirl.build(:category) })
    end
    discount_rate { rand(60) }
    duration_term 'minutes'
    title { FFaker::Product.product }
    secret_key { "#{title}_secret_key" }
    status true
    duration { Discount::DURATIONS.sample } # between 0h - 3 hours
    created_at Time.zone.now
    hashtags { (1..5).map { "##{FFaker::Lorem.word}" } }
  end
end
