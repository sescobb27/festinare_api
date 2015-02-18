class Type
  include Mongoid::Document

  # =============================relationships=================================
    # belongs_to :discount
    # belongs_to :client
    # belongs_to :user
    belongs_to :typeable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
    field :name
    field :description
    field :count, type: Integer, default: 0 # number of people interested in each Type
  # =============================END Schema====================================
end
