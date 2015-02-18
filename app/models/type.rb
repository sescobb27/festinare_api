class Type
  include Mongoid::Document

  # =============================relationships=================================
    # embedded_in :discount
    embedded_in :typeable, polymorphic: true
    belongs_to :client
    belongs_to :user
  # =============================END relationships=============================
  # =============================Schema========================================
    field :name
    field :description
    field :count, type: Integer # number of people interested in each Type
  # =============================END Schema====================================
end
