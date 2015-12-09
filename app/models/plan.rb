# == Schema Information
#
# Table name: plans
#
#  id               :integer          not null, primary key
#  name             :string(40)       not null
#  description      :text
#  price            :integer          not null
#  num_of_discounts :integer          not null
#  currency         :string           not null
#  expired_rate     :integer          not null
#  expired_time     :string           not null
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

# @author Simon Escobar
class Plan < ActiveRecord::Base
  # =============================relationships=================================
  has_many :clients_plans, inverse_of: :plan
  has_many :clients, through: :clients_plans
  # =============================END relationships=============================
  # =============================Schema========================================
  EXPIRED_TIMES = %w(day days month months).freeze
  scope :active_plans, -> { where(deleted_at: nil).asc(:price) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name,
            :description,
            :price,
            :num_of_discounts,
            :currency,
            :expired_rate,
            presence: true
  validates :expired_time, inclusion: {
    in: EXPIRED_TIMES,
    message: "Invalid Expired time, valid ones are (#{EXPIRED_TIMES.join(", ")})"
  }
  validates :price, numericality: { only_integer: true }
  validates :num_of_discounts, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }
  validates :expired_rate, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 31
  }
  # =============================END Schema Validations========================
end
