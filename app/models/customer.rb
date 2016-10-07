# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  fullname               :string(100)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

# @author Simon Escobar
class Customer < ActiveRecord::Base
  include User
  # =============================relationships=================================
  has_many :mobiles, inverse_of: :customer
  has_many :customers_discounts
  has_many :discounts, through: :customers_discounts
  has_many :locations, inverse_of: :customer
  # =============================END relationships=============================

  # =============================Schema========================================
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :fullname, presence: true
  # =============================END Schema Validations========================
  scope :near_location, lambda { |location, limit = 20|
    near([location.latitude, location.longitude], limit)
  }
end
