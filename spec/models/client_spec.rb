require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'Create Client' do
    let(:client) { FactoryGirl.create(:client) }
    let(:c_plan) { FactoryGirl.create(:client_with_plan) }
    let(:c_discount) { FactoryGirl.create(:client_with_discounts) }

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
      expect(Client.find_by(
        username: c_discount.username
      ).categories.count).to be > 0
    end
  end
end
