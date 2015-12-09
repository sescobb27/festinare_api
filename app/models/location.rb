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

# @author Simon Escobar
class Location < ActiveRecord::Base
  # =============================relationships=================================
  belongs_to :customer, inverse_of: :locations
  # =============================END relationships=============================
  # =============================Schema Validations============================
  validates :latitude, :longitude, presence: true, numericality: true
  # =============================END Schema Validations========================
  # =============================Geocoder======================================
  # geocoded_by :address   # can also be an IP address
  # reverse_geocoded_by :latitude, :longitude
  # after_validation :geocode, :reverse_geocode # auto-fetch coordinates
  # =============================END Geocoder==================================
end
