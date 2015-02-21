class Discount
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  # =============================relationships=================================
    has_many :categories, as: :categorizable, autosave: true
    embedded_in :discountable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
    field :discount_rate, type: Integer
    field :title
    field :secret_key
    field :status, type: Boolean, default: true
    field :duration, type: Integer
    field :hashtags, type: Array

    index({ status: 1 }, { unique: false, name: 'discount_status_index' })
    # index({ hashtags: 1 }, { unique: false, name: 'discount_hashtags_index' })
  # =============================END Schema====================================
end
