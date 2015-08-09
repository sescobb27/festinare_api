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

  it { should have_db_column(:token).of_type(:string) }
  it { should have_db_column(:enabled).of_type(:boolean) }
  it { should have_db_column(:platform).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }

  pending "add some examples to (or delete) #{__FILE__}"
end
