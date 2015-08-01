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
#

require 'rails_helper'

RSpec.describe CustomersDiscount, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
