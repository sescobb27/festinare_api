require 'rails_helper'

RSpec.describe Client, :type => :model do

  describe 'Create Client' do
    before :all do
      @client = FactoryGirl.build(:client)
    end

    it 'should create a full client' do
      expect(@client.categories.length).to be > 0
      expect(@client.discounts.length).to be > 0
      expect(@client.plans).to exist
      expect(@client.save).to be true
      expect(@client._id).not_to be nil
      @client.plans.each do |plan|
        expect(plan.clients).to include @client
      end
      @client.discounts.each do |discount|
        expect(discount.categories).to include @client.categories.sample
      end
      expect(Client.count).to eql 1
      expect(@client.discounts).to exist
    end

    it 'should have the all the attributes' do
      client = Client.includes(:plans, :categories).first
      expect(client.categories).to eq @client.categories
      expect(client.plans).to eq @client.plans
      expect(client.discounts).to eq @client.discounts
    end
  end
end
