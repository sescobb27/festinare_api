class Location
  include Mongoid::Document
  # =============================relationships=================================
    # embedded_in :client
    # embedded_in :user
    embedded_in :localizable, polymorphic: true
  # =============================END relationships=============================

  # =============================Schema========================================
    field :latitude, type: Float
    field :longitude, type: Float
  # =============================END Schema====================================
end
