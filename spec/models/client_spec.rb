# == Schema Information
#
# Table name: clients
#
#  id                     :integer          not null, primary key
#  name                   :string(120)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  image_url              :string
#  addresses              :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'Create Client' do
    let(:client) { FactoryGirl.create(:client) }
    let(:c_plan) { FactoryGirl.create(:client_with_plan) }
    let(:c_discount) { FactoryGirl.create(:client_with_discounts) }

    it 'should create a raw client' do
      expect(client.categories.length).to be > 0
      expect(client.save).to be true
      expect(client.id).not_to be nil
      cli = Client.find(client.id)
      client.categories.each do |category|
        expect(cli.categories).to include category
      end
    end

    it 'should create a client with discounts' do
      expect(c_discount.discounts.length).to be > 0
      expect(c_discount.save).to be true
      expect(c_discount.discounts).to exist
      expect(c_discount.id).not_to be nil
      expect(Client.find_by(
        username: c_discount.username
      ).categories.count).to be > 0
    end
  end
end
