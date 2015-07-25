class Location < ActiveRecord::Base
  # =============================relationships=================================
  # embedded_in :client
  # embedded_in :user
  belongs_to :localizable, polymorphic: true
  # =============================END relationships=============================

  # =============================Schema========================================
  # field :latitude, type: Float
  # field :longitude, type: Float
  # =============================END Schema====================================
end
