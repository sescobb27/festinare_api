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

require 'rails_helper'

RSpec.describe Plan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
