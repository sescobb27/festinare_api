class Category
  include Mongoid::Document

  # =============================relationships=================================
    # belongs_to :discount
    # belongs_to :client
    # belongs_to :user
    embedded_in :categorizable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
    field :name
    field :description
    field :count, type: Integer, default: 0 # number of people interested in each Type

    index({ name: 1 }, { unique: true, name: 'type_name_index' })
  # =============================END Schema====================================
end
