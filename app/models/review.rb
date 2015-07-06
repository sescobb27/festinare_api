class Review
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  # =============================relationships=================================
  belongs_to :user
  belongs_to :client
  # =============================END relationships=============================
  # =============================Schema========================================
  field :rate, type: Integer
  field :feedback
  # =============================END Schema====================================
  # =============================Schema Validations============================
  validates :feedback, presence: true
  validates :rate, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }
  # =============================END Schema Validations========================
end
