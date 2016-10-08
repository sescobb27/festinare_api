# == Schema Information
#
# Table name: discounts
#
#  id            :integer          not null, primary key
#  discount_rate :integer          not null
#  title         :string(100)      not null
#  secret_key    :string           not null
#  status        :boolean          default(TRUE)
#  duration      :integer          not null
#  duration_term :string           default("minutes")
#  hashtags      :string           default([]), is an Array
#  client_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'
require 'rake'

RSpec.describe Discount, type: :model do
  it { should belong_to :client }
  it { should have_many :customers_discounts }
  it { should have_many :customers }

  it { should validate_presence_of :discount_rate }
  it { should validate_presence_of :title }
  it { should validate_presence_of :duration }
  it { should validate_inclusion_of(:duration).in_array Discount::DURATIONS }

  it { should have_db_column(:discount_rate).of_type(:integer) }
  it { should have_db_column(:title).of_type(:string) }
  it { should have_db_column(:secret_key).of_type(:string) }
  it { should have_db_column(:status).of_type(:boolean) }
  it { should have_db_column(:duration).of_type(:integer) }
  it { should have_db_column(:duration_term).of_type(:string) }
  it { should have_db_column(:hashtags).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }

  describe '::redeem' do
    let(:discount) { FactoryGirl.create :discount, secret_key: 'MySecretKey' }
    let(:customer) { FactoryGirl.create :customer }

    before do
      discount.customers.push customer
      discount.save
    end

    it 'should redeem discount' do
      expect(Discount.redeem discount, 'MySecretKey').to be_truthy
      expect(discount.customers_discounts.first.redeemed?).to be_truthy
    end

    it 'should fail with SecretKeyNotMatchError' do
      expect { Discount.redeem discount, 'NotMatch' }.to raise_error(Discount::SecretKeyNotMatchError)
      expect(discount.customers_discounts.first.redeemed?).to be_falsy
    end

    it 'should fail with AlreadyRedeemedError' do
      Discount.redeem discount, 'MySecretKey'
      expect { Discount.redeem discount, 'MySecretKey' }.to raise_error(Discount::AlreadyRedeemedError)
      expect(discount.customers_discounts.first.redeemed?).to be_truthy
    end
  end

  describe '#expired?(Time.zone.now)' do
    pending 'status false'
    pending 'expired'
    pending 'unexpired'
  end

  describe '#expire_time' do
    pending 'get expire time'
  end
end
