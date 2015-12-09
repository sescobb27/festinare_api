# == Schema Information
#
# Table name: customers_discounts
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  discount_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rate        :integer
#  feedback    :string(140)
#  redeemed    :boolean
#

# @author Simon Escobar
class CustomersDiscount < ActiveRecord::Base
  belongs_to :customer
  belongs_to :discount

  validates :rate, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }, allow_nil: true
end
