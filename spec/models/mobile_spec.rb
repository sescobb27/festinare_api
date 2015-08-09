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

require 'rails_helper'

RSpec.describe Mobile, type: :model do
  it { should belong_to :customer }
  it { should validate_presence_of :token }
  it { should validate_presence_of :platform }

  pending "add some examples to (or delete) #{__FILE__}"
end
