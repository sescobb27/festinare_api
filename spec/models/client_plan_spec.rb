require 'rails_helper'
require 'rake'

RSpec.describe ClientPlan, type: :model do
  describe 'invalidate:plans Task -> Invalidate Expired Plans' do
    let!(:expired_clients) do
      FactoryGirl.create_list :client_with_expired_plan, 10
    end
    let!(:clients) do
      FactoryGirl.create_list :client_with_plan, 10
    end

    it 'should invalidate all expired plans' do
      Rake::Task['invalidate:plans'].invoke
      clients.each do |client|
        expect(Client.find(client._id).client_plans).not_to be_empty
      end
      expired_clients.each do |client|
        expect(Client.find(client._id).client_plans.with_discounts).to be_empty
      end
    end
  end
end
