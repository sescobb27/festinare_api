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
  index({ token: 1 }, unique: true, name: 'token_index')
  index({ platform: 1 }, unique: false, name: 'platform_index')
  # =============================END Schema====================================
  # =============================Schema Validations============================
  validates :token, :platform, presence: true
  # =============================END Schema Validations========================
end
