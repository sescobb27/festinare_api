# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  fullname               :string(100)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

require 'rails_helper'
require 'rake'

# array_length_gte => array length greater than or eql
RSpec::Matchers.define :array_length_gte do
  match do |actual|
    actual.length >= 1000
  end
end

RSpec.describe Customer, type: :model do
  it { should have_many :mobiles }
  it { should have_many :customers_discounts }
  it { should have_many :discounts }
  it { should have_many :locations }

  it { should validate_presence_of :fullname }

  it { should have_db_column(:fullname).of_type(:string) }
  it { should have_db_column(:categories).of_type(:string) }
  it { should have_db_column(:tokens).of_type(:string) }
  it { should have_db_column(:username).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
  it { should have_db_column(:email).of_type(:string) }
  it { should have_db_column(:encrypted_password).of_type(:string) }
  it { should have_db_column(:reset_password_token).of_type(:string) }
  it { should have_db_column(:reset_password_sent_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_token).of_type(:string) }
  it { should have_db_column(:confirmed_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_sent_at).of_type(:datetime) }

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
      customer = FactoryGirl.attributes_for :customer_with_subscriptions
      expect { Customer.create!(customer) }.to_not raise_error
      u = Customer.find_by(username: customer[:username])
      u.categories.each do |category|
        expect(customer[:categories]).to include category
      end
    end
  end

  describe 'send:notification Task -> Send Customer Notifications' do
    skip 'should send notification to customer' do
      FactoryGirl.create_list :client_with_discounts, 20

      threads = []
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      threads.each(&:join)
      expect(Customer.count).to be >= 1000
      expect(@gcm).to receive(:send_notification).at_least(:once).with(
        array_length_gte(1000), instance_of(Hash)
      )
      Rake::Task['send:notification'].invoke
    end
  end
end
