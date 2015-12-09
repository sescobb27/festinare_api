# == Schema Information
#
# Table name: mobiles
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  token       :string           not null
#  enabled     :boolean          default(TRUE)
#  platform    :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'securerandom'

FactoryGirl.define do
  factory :mobile do
    token { SecureRandom.base64 }
    platform { %w(android apple).sample }
  end
end
