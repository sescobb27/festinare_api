class CustomersDiscount < ActiveRecord::Base
  belongs_to :customer
  belongs_to :discount

  validates :rate, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }
end
