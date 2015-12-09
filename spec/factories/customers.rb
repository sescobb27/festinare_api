# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  fullname               :string(100)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
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
  factory :customer do
    username  { "#{FFaker::Internet.user_name}#{SecureRandom.base64(4)}".downcase }
    fullname { FFaker::Name.name + FFaker::Name.last_name }
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
    tokens { [SecureRandom.base64] }

    factory :customer_with_subscriptions do
      categories do
        User::CATEGORIES.sample(2)
      end
    end

    factory :customer_with_mobile do
      categories do
        User::CATEGORIES.sample(2)
      end
      mobiles { FactoryGirl.create_list :mobile, 1 }
    end

    factory :customer_with_discounts do
      discounts { FactoryGirl.create_list :discounts, 5 }
    end
  end
end
