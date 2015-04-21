require 'rails_helper'
require 'rake'

RSpec.describe ClientPlan, type: :model do
  describe 'invalidate:plans Task -> Invalidate Expired Plans' do
    before { Festinare::Application.load_tasks }
    let!(:expired_clients) {
      c_attrs = (1..10).map {
        FactoryGirl.attributes_for :client_with_expired_plan
      }
      Client.create c_attrs
    }
    let!(:clients) {
      c_attrs = (1..10).map { FactoryGirl.attributes_for :client_with_plan }
      Client.create c_attrs
    }

    it 'should invalidate all expired plans' do
      Rake::Task['invalidate:plans'].invoke
      clients.each do |client|
        expect(Client.find(client._id).client_plans).not_to be_empty
      end
      expired_clients.each do |client|
        expect(Client.find(client._id).client_plans).to be_empty
      end
    end
  end
end
