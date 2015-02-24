require 'rails_helper'

RSpec.describe Client, :type => :model do

  describe 'Create Client' do
    let!(:client) { FactoryGirl.build(:client) }
    let!(:c_plan) { FactoryGirl.build(:client_with_plans) }
    let!(:c_discount) { FactoryGirl.build(:user_with_discounts) }

    it 'should create a raw client' do
      expect(client.categories.length).to be > 0
      expect(client.save).to be true
      expect(client._id).not_to be nil
      cli = Client.find(client._id)
      client.categories.each do |category|
        expect(cli.categories).to include category
      end
    end

    it 'should create a client with discounts' do
      expect(c_discount.discounts.length).to be > 0
      expect(c_discount.save).to be true
      expect(c_discount.discounts).to exist
      expect(c_discount._id).not_to be nil
      expect(Client.find_by(username: c_discount.username).categories.count()).to be > 0
    end

    it 'should create a client with plan' do
      expect(c_plan.plans).to exist
      expect(c_plan.save).to be true
      expect(c_plan._id).not_to be nil
      c_plan.plans.each do |plan|
        expect(plan.clients).to include c_plan
      end
    end
  end
end
