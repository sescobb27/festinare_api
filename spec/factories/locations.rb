# == Schema Information
#
# Table name: locations
#
#  id          :integer          not null, primary key
#  latitude    :float
#  longitude   :float
#  address     :string
#  customer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'ffaker'

FactoryGirl.define do
  factory :location do
    latitude 1.5
    longitude 1.5
    address { FFaker::Address.street_address }
  end
end
