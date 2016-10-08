require 'rails_helper'

RSpec.describe NotificationService  do
  before do
    @gcm = instance_double(GCM)
    allow(@gcm).to receive(:send_notification).with(
      instance_of(Array), instance_of(Hash)
    ).and_return []
    allow(Gcm::Notification).to(
      receive(:instance).and_return(@gcm)
    )
  end

  describe '::notify_customers' do
    skip 'should send notification to customer' do
      FactoryGirl.create_list :client_with_discounts, 20

      threads = []
      10.times do
        threads << Thread.new { FactoryGirl.create_list :customer_with_mobile, 100 }
      end
      threads.each(&:join)
      expect(Customer.count).to be >= 1000
      expect(@gcm).to receive(:send_notification).at_least(:once).with(
        array_length_gte(1000), instance_of(Hash)
      )
      # Rake::Task['send:notification'].invoke
      NotificationService.notify_customers
    end
  end
end
