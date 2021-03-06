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

  let(:client) { FactoryGirl.create(:client) }
  let(:c_plan) { FactoryGirl.create(:client_with_plan) }
  let(:c_discount) { FactoryGirl.create(:client_with_discounts) }
  let(:c_expired) { FactoryGirl.create(:client_with_expired_plan) }

  describe 'Create Client' do
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
    it 'should not have plan' do
      expect(client.plan?).to be_falsey
    end

    it 'should not have plan if expired plan' do
      expect(c_expired.plan?).to be_falsey
    end

    it 'should have a valid plan' do
      expect(c_plan.plan?).to be_truthy
    end

    it 'should have at least one valid plan' do
      c_plan.purchase Plan.all.sample
      expect(c_plan.plan?).to be_truthy
    end
  end

  describe '#decrement_num_of_discounts_left!' do
    it 'should fail if no active plan' do
      expect { client.decrement_num_of_discounts_left! }.to raise_error ClientsPlan::PlanDiscountsExhausted
    end

    it 'should fail if no discounts left' do
      client_plan = c_plan.clients_plans.last
      client_plan.num_of_discounts_left = 0
      client_plan.save
      expect { c_plan.decrement_num_of_discounts_left! }.to raise_error ClientsPlan::PlanDiscountsExhausted
    end

    it 'should decresed num of discounts' do
      plan = c_plan.plans.last
      expect(c_plan.decrement_num_of_discounts_left!
                   .clients_plans
                   .last
                   .num_of_discounts_left
            ).to eql plan.num_of_discounts - 1
    end
  end

  describe '#unexpired_discounts(Time.zone.now)' do
    it 'should not have discounts' do
      expect(client.unexpired_discounts(Time.zone.now)).to eql []
    end

    it 'should have expired discounts' do
      expired_discounts = c_discount.discounts.sample(2)
      expired_discounts.map do |discount|
        discount.created_at = (discount.created_at - (discount.duration * 60).seconds - 1.second)
      end
      unexpired = c_discount.unexpired_discounts(Time.zone.now)
      expect(unexpired).not_to include expired_discounts[0]
      expect(unexpired).not_to include expired_discounts[1]
    end

    it 'should return all discounts' do
      unexpired = c_discount.unexpired_discounts(Time.zone.now)
      expect(unexpired.length).to eql 5
      expect(unexpired).to match_array c_discount.discounts
    end
  end

  describe '#update_with_password(credentials)' do
    it 'invalid password' do
      updated = client.update_with_password current_password: 'wrongpassword'
      expect(updated).to be_falsey
      expect(client.errors.full_messages).to include 'Current password is invalid'
    end

    it 'password != password_confirmation' do
      updated = client.update_with_password current_password: client.password,
                                            password: 'mynewpassword',
                                            password_confirmation: 'mynewpassword_notmatch'
      expect(updated).to be_falsey
      expect(client.errors.full_messages).to include 'Password confirmation doesn\'t match Password'
    end

    it 'password updated' do
      updated = client.update_with_password current_password: client.password,
                                            password: 'mynewpassword',
                                            password_confirmation: 'mynewpassword'
      expect(updated).to be_truthy
      expect(client.valid_password? 'mynewpassword').to be_truthy
    end
  end

  describe 'invalidate tokens' do
    let!(:clients) { FactoryGirl.create_list :client, 10, tokens: [] }

    it 'should invalidate all tokens' do
      # create an expired token
      clients.each do |client|
        token = JWT::AuthToken.make_token({ id: client.id }, Time.now.to_i - 5)
        client.tokens << token
        client.save
      end
      Client.invalidate_tokens!
      Client.select(:id, :tokens).find_each do |model|
        expect(model.tokens).to be_empty
      end
    end

    it 'should invalidate some tokens' do
      clients_with_tokens = FactoryGirl.create_list :client, 10, tokens: []
      # create an expired token
      clients.each do |client|
        token = JWT::AuthToken.make_token({ id: client.id }, Time.now.to_i - 5)
        client.tokens << token
        client.save
      end

      clients_with_tokens.each do |client|
        token = JWT::AuthToken.make_token({ id: client.id }, Time.now.to_i + 1_000)
        client.tokens << token
        client.save
      end

      Client.invalidate_tokens!

      clients_with_no_token_ids = clients.map(&:id)
      Client.select(:id, :tokens).find_each do |model|
        if clients_with_no_token_ids.include? model.id
          expect(model.tokens).to be_empty
        else
          expect(model.tokens).not_to be_empty
        end
      end
    end
  end
end
