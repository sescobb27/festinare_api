require 'ffaker'

FactoryGirl.define do
  factory :discount do
    types         Type.all #.sample rand(1..3)
    discount_rate { rand(60) }
    title         Faker::Product.product
    secret_key    'custom_secret_key'
    status        true
    duration      { rand(10800) } # between 0h - 3 hours
    created_at    Time.now
    hashtags      (1..5).map { "##{Faker::Lorem.word}" }
  end

end
