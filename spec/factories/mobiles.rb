require 'securerandom'

FactoryGirl.define do
  factory :mobile do
    token { SecureRandom.base64 }
    platform { %w(android apple).sample }
  end
end
