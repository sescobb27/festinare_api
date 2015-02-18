class Plan
  include Mongoid::Document
  # =============================relationships=================================
    has_and_belongs_to_many :clients
  # =============================END relationships=============================
  # =============================Schema========================================
    field :name
    field :description
    field :status, type: Boolean, default: true
    field :price, type: Integer
    field :num_of_discounts, type: Integer

    index({ name: 1 }, { unique: true, name: 'plan_name_index' })
    index({ status: 1 }, { unique: false, name: 'plan_status_index' })
  # =============================END Schema====================================

  default_scope -> { asc(:price) }
end
