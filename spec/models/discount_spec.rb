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

  describe '::discount_categories' do
    it 'should return all categories' do
      FactoryGirl.create_list :client_with_discounts, 10
      categories = Discount.discount_categories
      # expect(categories).to eql User::CATEGORIES
      expect(categories - User::CATEGORIES).to eql []
    end
  end
end
