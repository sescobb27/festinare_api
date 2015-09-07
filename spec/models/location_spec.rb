# == Schema Information
#
# Table name: locations
#
#  id          :integer          not null, primary key
#  latitude    :float
#  longitude   :float
#  address     :string
#  customer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Location, type: :model do
  it { should belong_to :customer }

  it { should validate_numericality_of :latitude }
  it { should validate_numericality_of :longitude }

  it { should have_db_column(:latitude).of_type(:float) }
  it { should have_db_column(:longitude).of_type(:float) }
  it { should have_db_column(:address).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
end
