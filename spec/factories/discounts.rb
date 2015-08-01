# == Schema Information
#
# Table name: discounts
#
#  id            :integer          not null, primary key
#  discount_rate :integer          not null
#  title         :string(100)      not null
#  secret_key    :string           not null
#  status        :boolean          default(TRUE)
#  duration      :integer          not null
#  duration_term :string           default("minutes")
#  hashtags      :string           default([]), is an Array
#  client_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'ffaker'

FactoryGirl.define do
  factory :discount do
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
