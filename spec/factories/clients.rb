# == Schema Information
#
# Table name: clients
#
#  id                     :integer          not null, primary key
#  name                   :string(120)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  image_url              :string
#  addresses              :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :client do
    categories do
      User::CATEGORIES.sample(2)
    end
    # locations { (1..5).map { FactoryGirl.build(:location) } }
    username { "#{SecureRandom.base64(4)}#{FFaker::Internet.user_name}".downcase }
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
    name { "#{FFaker::Company.name}#{SecureRandom.base64(4)}" }
    image_url { FFaker::Internet.http_url }
    addresses { (1..5).map { FFaker::Address.street_address } }
    tokens { [SecureRandom.base64] }
    factory :client_with_discounts do
      discounts { FactoryGirl.create_list :discount, 5 }
    end
    factory :client_with_plan do
      after(:create) do |client|
        client.purchase Plan.all.sample
      end
    end
    factory :client_with_expired_plan do
      after(:create) do |client|
        client.purchase Plan.all.sample do |plan|
          plan.expired_date = Time.zone.now - 1.minute
        end
      end
    end
  end
end
