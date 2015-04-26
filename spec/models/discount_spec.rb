require 'rails_helper'
require 'rake'

RSpec.describe Discount, type: :model do
  describe 'invalidate:discounts Task -> Invalidate Expired Discounts' do
    let!(:clients) do
      (1..20).map do
        FactoryGirl.attributes_for :client_with_discounts
      end
    end

    it 'should invalidate all discounts' do
      created_clients = Client.create clients
      threads = []
      created_clients.map do |client|
        client.discounts.map do |discount|
          threads << Thread.new(discount) do |t_discount|
            t_discount.set created_at: (
              t_discount.created_at - (
                t_discount.duration * 60
              ).seconds - 1.second
            )
          end
        end
      end
      expect(threads.length).to eql 100
      threads.map!(&:join)
      threads.clear

      Rake::Task['invalidate:discounts'].invoke

      created_clients.map do |client|
        client.reload.discounts.unscoped.map! do |discount|
          threads << Thread.new(discount) do |t_discount|
            expect(t_discount.status).to eql false
          end
        end
      end
      expect(threads.length).to eql 100
      threads.map!(&:join)
    end
  end
end
