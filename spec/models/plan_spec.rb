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
  it { should have_many :clients_plans }
  it { should have_many :clients }

  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_presence_of :price }
  it { should validate_presence_of :num_of_discounts }
  it { should validate_presence_of :currency }
  it { should validate_presence_of :expired_rate }
  it { should validate_inclusion_of(:expired_time).in_array Plan::EXPIRED_TIMES }
  it { should validate_numericality_of(:price).only_integer }
  it { should validate_numericality_of(:num_of_discounts).only_integer }
  it { should validate_numericality_of(:expired_rate).only_integer }

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:description).of_type(:text) }
  it { should have_db_column(:price).of_type(:integer) }
  it { should have_db_column(:num_of_discounts).of_type(:integer) }
  it { should have_db_column(:currency).of_type(:string) }
  it { should have_db_column(:expired_rate).of_type(:integer) }
  it { should have_db_column(:expired_time).of_type(:string) }
  it { should have_db_column(:deleted_at).of_type(:datetime) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }

  pending "add some examples to (or delete) #{__FILE__}"
end
