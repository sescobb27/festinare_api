require 'rails_helper'
require 'rake'

RSpec::Matchers.define :array_length_greater_than_or_eql do
  match { |actual|
    puts "ACTUAL ==> #{actual.length}"
    actual.length >= 1000
  }
end

RSpec.describe User, type: :model do
  describe 'User with categories' do
    it 'should have some categories' do
      (1..10).each do
        user = FactoryGirl.attributes_for :user
        user[:categories] = []
        user[:categories].concat((1..2).map { FactoryGirl.build(:category) })
        expect { User.create!(user) }.to_not raise_error
        u = User.find_by(username: user[:username])
        u.categories.each do |category|
          expect(user[:categories]).to include category
        end
      end
    end
  end

  describe 'send:notification Task -> Send User Notifications' do
    before do
      @gcm = instance_double(GCM)
      allow(@gcm).to receive(:send_notification).with(
        instance_of(Array), instance_of(Hash)
      ).and_return []
      allow(Gcm::Notification).to(
        receive(:instance).and_return(@gcm)
      )

      Festinare::Application.load_tasks
    end

    it 'should send notification to users' do
      User.delete_all('$or': [
        { categories: { '$exists' => false } },
        { mobile: { '$exists' => false } }
      ])
      client_with_discounts = (1..20).map {
        FactoryGirl.attributes_for :client_with_discounts
      }
      Client.create client_with_discounts

      threads = []
      (1..100).each do
        threads << Thread.new do
          user_with_mobile = (1..10).map {
            FactoryGirl.attributes_for :user_with_mobile
          }
          users = User.create user_with_mobile
          Thread.current[:users] = users
        end
      end

      created_users = []
      threads.map! do |thread|
        thread.join
        created_users.concat thread[:users]
      end

      expect(created_users.length).to eql 1000
      expect(User.count).to be >= 1000
      expect(@gcm).to receive(:send_notification).at_least(:once).with(
        array_length_greater_than_or_eql(1000), instance_of(Hash)
      )
      Rake::Task['send:notification'].invoke
    end
  end
end
