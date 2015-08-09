require 'rails_helper'
require 'rake'

RSpec.describe ClientsPlan, type: :model do
  describe 'invalidate:plans Task -> Invalidate Expired Plans' do
    it { should belong_to :client }
    it { should belong_to :plan }

    let!(:expired_clients) do
      FactoryGirl.create_list :client_with_expired_plan, 10
    end
    let!(:clients) do
      FactoryGirl.create_list :client_with_plan, 10
    end

    it 'should invalidate all expired plans' do
      Rake::Task['invalidate:plans'].invoke
      clients.each do |client|
        expect(Client.joins(:clients_plans).find(client.id).clients_plans).not_to be_empty
      end
      expired_clients.each do |client|
        expect(Client.joins(:clients_plans).find(client.id).clients_plans.with_discounts).to be_empty
      end
    end
  end
end
