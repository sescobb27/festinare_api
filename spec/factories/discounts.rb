require 'ffaker'

FactoryGirl.define do
  factory :discount do
    after(:build)     { |discount| discount.categories.concat( (1..2).map { FactoryGirl.build(:category) }) }
    discount_rate { rand(60) }
    title         { Faker::Product.product }
    secret_key    { "#{title}_secret_key" }
    status        true
    duration      { rand(10800) } # between 0h - 3 hours
    created_at    Time.now
    hashtags      { (1..5).map { "##{Faker::Lorem.word}" }}
  end

end
