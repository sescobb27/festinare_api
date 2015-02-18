class Plan
  include Mongoid::Document
  # =============================relationships=================================
    has_and_belongs_to_many :clients
  # =============================END relationships=============================
  # =============================Schema========================================
    flied :name
    flied :description
    flied :status, type: Boolean
    flied :price, type: Integer
    flied :num_of_discounts, type: Integer

    index({ name: 1 }, { unique: true, name: 'plan_name_index' })
  # =============================END Schema====================================
end
