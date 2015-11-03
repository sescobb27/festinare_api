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

  describe 'invalidate:discounts Task -> Invalidate Expired Discounts' do
    it 'should invalidate all discounts' do
      clients = FactoryGirl.create_list :client_with_discounts, 20
      clients.each do |client|
        client.discounts.each do |discount|
          discount.update created_at: (
            discount.created_at - (discount.duration * 60).seconds - 1.second
          )
        end
      end

      Rake::Task['invalidate:discounts'].invoke

      clients = Client.includes(:discounts).find(clients.map(&:id))
      clients.each do |client|
        client.discounts.each do |discount|
          expect(discount.status).to eql false
        end
      end
    end
  end

  describe '::categories' do
    it 'should return all categories' do
      FactoryGirl.create_list :client_with_discounts, 10
      categories = Discount.categories
      # expect(categories).to eql User::CATEGORIES
      expect(categories - User::CATEGORIES).to eql []
    end

    pending 'no clients with active discounts'
  end

  describe '::available(categories, opts)' do
    before(:example, create_list: :clients) do
      @l_clients_with_discounts = FactoryGirl.create_list :client_with_discounts, 20
    end

    it 'should not have available discounts' do
      expect(Discount.available(User::CATEGORIES)).to eql []
    end

    it 'should return all discounts if no categories specifyed', create_list: :clients do
      available_discounts = Discount.available
      expect(available_discounts.length).to eql 100
      expect(available_discounts).to match_array @l_clients_with_discounts.flat_map(&:discounts)
    end

    it 'should not have available discounts if all of them are expired', create_list: :clients do
      @l_clients_with_discounts.each do |client|
        client.discounts.map do |discount|
          discount.update created_at: (discount.created_at - (discount.duration * 60).seconds - 1.second)
        end
      end
      expect(Discount.available.length).to eql 0
    end

    it 'all available discounts', create_list: :clients do
      User::CATEGORIES.each do |category|
        available_discounts = Discount.available([category])
        expect(available_discounts).not_to be_empty
        expect(available_discounts.flat_map(&:client).uniq).to match_array @l_clients_with_discounts
      end
    end

    it 'all available discounts with limit', create_list: :clients do
      User::CATEGORIES.each do |category|
        available_discounts = Discount.available([category], limit: 10)
        expect(available_discounts).not_to be_empty
        expect(available_discounts.length).to eql 10
        # available_discounts would match the first 2 clients given that we request
        # 10 discounts and all test :client_with_discounts generate 5 discounts, so
        # you do the math
        expect(available_discounts.flat_map(&:client).uniq).to match_array @l_clients_with_discounts.take 2
      end
    end
  end

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
