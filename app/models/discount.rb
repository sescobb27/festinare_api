class Discount
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Paranoia
  # =============================relationships=================================
    embeds_many :categories, as: :categorizable
    embedded_in :discountable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
    field :discount_rate, type: Integer
    field :title
    field :secret_key
    field :status, type: Boolean, default: true
    field :duration, type: Integer
    field :duration_term
    field :hashtags, type: Array

    index({ status: 1 }, { unique: false, name: 'discount_status_index' })
    # index({ hashtags: 1 }, { unique: false, name: 'discount_hashtags_index' })
  # =============================END Schema====================================
  default_scope -> { where(status: true) }
  DURATION_TERM = 'minutes'.freeze
  DURATIONS = [10, 20, 30, 60, 90, 120].freeze;
end
