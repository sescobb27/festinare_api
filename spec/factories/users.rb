require 'ffaker'
require 'securerandom'

FactoryGirl.define do
  factory :user do
    username  do
      "#{FFaker::Internet.user_name}#{SecureRandom.base64(4)}".downcase
    end
    email { "#{SecureRandom.base64(4)}#{FFaker::Internet.email}".downcase }
    password 'qwertyqwerty'
  end
end
