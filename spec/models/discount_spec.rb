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
