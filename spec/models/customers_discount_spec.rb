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
  it { should belong_to :customer }
  it { should belong_to :discount }

  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
  it { should have_db_column(:rate).of_type(:integer) }
  it { should have_db_column(:feedback).of_type(:string) }
end
