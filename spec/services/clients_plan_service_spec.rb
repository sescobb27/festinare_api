require 'rails_helper'

RSpec.describe ClientsPlanService do
  describe '::invalidate_expired_plans!' do
    let!(:expired_clients) do
      FactoryGirl.create_list :client_with_expired_plan, 10
    end
    let!(:clients) do
      FactoryGirl.create_list :client_with_plan, 10
    end

    it 'should invalidate all expired plans' do
      # Rake::Task['invalidate:plans'].invoke
      ClientsPlanService.invalidate_expired_plans!
      clients.each do |client|
        expect(Client.joins(:clients_plans).find(client.id).clients_plans).not_to be_empty
      end
      expired_clients.each do |client|
        expect(Client.joins(:clients_plans).find(client.id).clients_plans.with_discounts).to be_empty
      end
    end
  end
end
