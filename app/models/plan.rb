class Plan
  include Mongoid::Document
  include Mongoid::Paranoia
  # =============================Schema========================================
    field :name
    field :description
    field :status, type: Boolean, default: true
    field :price, type: Integer
    field :num_of_discounts, type: Integer
    field :currency
    field :expired_rate, type: Integer # (1 .. 31) days or (1 .. 12) months
    field :expired_time # ( days or months )

    index({ name: 1 }, { unique: true, name: 'plan_name_index' })
    index({ status: 1 }, { unique: false, name: 'plan_status_index' })
  # =============================END Schema====================================

  default_scope -> { where(status: true).asc(:price) }
end
