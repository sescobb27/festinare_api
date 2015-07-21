require 'rails_helper'
require 'rake'

RSpec::Matchers.define :array_length_greater_than_or_eql do
  match do |actual|
    actual.length >= 1000
  end
end

RSpec.describe Customer, type: :model do
  before do
    @gcm = instance_double(GCM)
    allow(@gcm).to receive(:send_notification).with(
      instance_of(Array), instance_of(Hash)
    ).and_return []
    allow(Gcm::Notification).to(
      receive(:instance).and_return(@gcm)
    )
  end

  describe 'Customer with categories' do
    it 'should have some categories' do
      (1..10).each do
        customer = FactoryGirl.attributes_for :customer
        customer[:categories] = []
        customer[:categories].concat((1..2).map { FactoryGirl.build(:category) })
        expect { Customer.create!(customer) }.to_not raise_error
        u = Customer.find_by(username: customer[:username])
        u.categories.each do |category|
          expect(customer[:categories]).to include category
        end
      end
    end
  end

  describe 'send:notification Task -> Send Customer Notifications' do
    skip 'should send notification to customer' do
      Customer.delete_all('$or': [
        { categories: { '$exists' => false } },
        { mobile: { '$exists' => false } }
      ])

      FactoryGirl.create_list :client_with_discounts, 20

      threads = []
      (1..100).each do
        threads << Thread.new do
          customer = FactoryGirl.create_list :customer_with_mobile, 10
          Thread.current[:customers] = customer
        end
        threads.map!(&:join) if threads.length >= ENV['POOL_SIZE'].to_i
      end

      created_customer = []
      threads.map! do |thread|
        thread.join
        created_customer.concat thread[:customers]
      end

      expect(created_customer.length).to eql 1000
      expect(Customer.count).to be >= 1000
      expect(@gcm).to receive(:send_notification).at_least(:once).with(
        array_length_greater_than_or_eql(1000), instance_of(Hash)
      )
      Rake::Task['send:notification'].invoke
    end
  end
end
