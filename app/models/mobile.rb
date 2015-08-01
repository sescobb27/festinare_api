# == Schema Information
#
# Table name: mobiles
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  token       :string           not null
#  enabled     :boolean          default(TRUE)
#  platform    :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Mobile < ActiveRecord::Base
  # =============================relationships=================================
  belongs_to :customer
  # =============================END relationships=============================
  # =============================Schema========================================
  # =============================END Schema====================================
  # =============================Schema Validations============================
  validates :token, :platform, presence: true
  # =============================END Schema Validations========================
end
