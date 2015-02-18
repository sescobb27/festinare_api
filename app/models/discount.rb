class Discount
  include Mongoid::Document
  # =============================relationships=================================
    has_many :types, as: :typeable
    embedded_in :discountable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
    field :discount_rate, type: Integer
    field :title
    field :secret_key
    field :status, type: Boolean
    field :duration, type: Integer
    field :created_at, type: DateTime
    field :hashtags, type: Array

    index({ status: 1 }, { unique: false, name: 'discount_status_index' })
    index({ hashtags: 1 }, { unique: false, name: 'discount_hashtags_index' })
  # =============================END Schema====================================
end
