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
  it { should have_many :clients_plans }
  it { should have_many :plans }
  it { should have_many :discounts }
  it { should have_many :customers_discounts }

  it { should validate_presence_of :name }

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:categories).of_type(:string) }
  it { should have_db_column(:tokens).of_type(:string) }
  it { should have_db_column(:username).of_type(:string) }
  it { should have_db_column(:image_url).of_type(:string) }
  it { should have_db_column(:addresses).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
  it { should have_db_column(:email).of_type(:string) }
  it { should have_db_column(:encrypted_password).of_type(:string) }
  it { should have_db_column(:reset_password_token).of_type(:string) }
  it { should have_db_column(:reset_password_sent_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_token).of_type(:string) }
  it { should have_db_column(:confirmed_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_sent_at).of_type(:datetime) }

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

  describe '#plan?' do
    pending 'no plan'
    pending 'expired plan'
    pending 'valid plan'
  end

  describe '#decrement_num_of_discounts_left!' do
    pending 'no plan'
    pending 'no discounts left'
    pending 'num of discounts decresed'
  end

  describe '#unexpired_discounts(Time.zone.now)' do
    pending 'no discounts'
    pending 'expired discounts'
    pending 'no expired discounts'
  end

  describe '#update_password(credentials)' do
    pending 'valid password'
    pending 'invalid password'
    pending 'password != password_confirmation'
    pending 'password updated'
  end

  describe '::available_discounts(categories, opts)' do
    pending 'no available discounts'
    pending 'empty categories'
    pending 'clients does not have available discounts'
    pending 'clients with expired discounts'
    pending 'all available discounts'
  end
end
