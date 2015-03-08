class Mobile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  # =============================relationships=================================
    embedded_in :user
  # =============================END relationships=============================
  # =============================Schema========================================
    field :token
    field :enabled, type: Boolean, default:  true
    field :platform
    index({ token: 1 }, { unique: true, name: 'token_index' })
  # =============================END Schema====================================
end
