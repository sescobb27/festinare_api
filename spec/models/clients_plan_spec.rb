# == Schema Information
#
# Table name: clients_plans
#
#  id                    :integer          not null, primary key
#  client_id             :integer
#  plan_id               :integer
#  num_of_discounts_left :integer          not null
#  status                :boolean          default(TRUE)
#  expired_date          :datetime         not null
#  created_at            :datetime         not null
#

require 'rails_helper'
require 'rake'

RSpec.describe ClientsPlan, type: :model do
  it { should belong_to :client }
  it { should belong_to :plan }

  it { should have_db_column(:num_of_discounts_left).of_type(:integer) }
  it { should have_db_column(:status).of_type(:boolean) }
  it { should have_db_column(:expired_date).of_type(:datetime) }
  it { should have_db_column(:created_at).of_type(:datetime) }

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
        expect(Client.joins(:clients_plans).find(client.id).clients_plans).not_to be_empty
      end
      expired_clients.each do |client|
        expect(Client.joins(:clients_plans).find(client.id).clients_plans.with_discounts).to be_empty
      end
    end
  end
end
