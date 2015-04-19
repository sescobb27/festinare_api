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
  CATEGORIES = ['Bar', 'Disco', 'Restaurant'].freeze
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name, inclusion: { in: CATEGORIES }
  # =============================END Schema Validations========================
end
