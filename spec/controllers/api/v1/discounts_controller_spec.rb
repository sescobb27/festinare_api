require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe DiscountsController, type: :controller  do
      def jwt_validate_token(user)
        @auth_token = allow(JWT::AuthToken).to(
          receive(:validate_token).and_return(
            _id: user._id,
            username: user.username,
            email: user.email
          )
        )
      end

      before do
        request.host = 'example.com'
        client_id = rand(100)

        expect(post: "http://#{request.host}/api/v1/clients/#{client_id}/discounts").to(
          route_to(
            controller: 'api/v1/discounts',
            action: 'create',
            format: :json,
            client_id: "#{client_id}"
          )
        )

        expect(get: "http://#{request.host}/api/v1/discounts").to(
          route_to(
            controller: 'api/v1/discounts',
            action: 'index',
            format: :json
          )
        )
        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
      end

      let(:clients) do
        c_with_discounts = (1..10).map {
          FactoryGirl.attributes_for :client_with_discounts
        }
        Client.create c_with_discounts
      end

      # let(:clients) {
      #   (1..10).map { FactoryGirl.create :client_with_discounts }
      # }

      let(:users) do
        u_with_subscriptions = (1..10).map {
          FactoryGirl.attributes_for :user_with_subscriptions
        }
        User.create u_with_subscriptions
      end

      let(:raw_users) do
        user_s = (1..10).map { FactoryGirl.attributes_for :user }
        User.create user_s
      end

      describe 'Create Discount' do
        let(:raw_client) do
          client_attr = FactoryGirl.attributes_for :client
          Client.create client_attr
        end

        let(:client) do
          client_attr = FactoryGirl.attributes_for :client_with_plan
          Client.create client_attr
        end

        let(:discount) { FactoryGirl.attributes_for(:discount) }

        before do
          jwt_validate_token client
        end

        it 'should be able to create a discount' do
          post :create, client_id: client._id, discount: discount.to_hash
          expect(response.status).to eql 200

          client_discount = Client.find(client._id).discounts.first

          expect(client_discount.discount_rate).to eql discount[:discount_rate]
          expect(client_discount.title).to eql discount[:title]
          expect(client_discount.secret_key).to eql discount[:secret_key]
          expect(client_discount.status).to eql discount[:status]
          expect(client_discount.duration).to eql discount[:duration]
          expect(client_discount.hashtags).to eql discount[:hashtags]

          c = Client.find(client._id)
          plan = c.client_plans.first
          expect(plan.num_of_discounts_left).to eql plan.num_of_discounts - 1

          Cache::RedisCache.instance do |redis|
            len = redis.llen('discounts')
            expect(len).to be > 0
            obj = redis.lrange('discounts', len - 1, len - 1)[0]
            cache_discount = JSON.parse(obj)
            expect(cache_discount['discount']['title']).to eql client_discount.title
            expect(cache_discount['discount']['_id']['$oid']).to eql client_discount._id.to_s
          end
        end

        it 'should not be able to create a discount' do
          discount[:duration] = [0, 15, 25, 35, 65, 95, 125].sample
          post :create, client_id: client._id, discount: discount.to_hash
          expect(response.status).to eql 400
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response_body[:errors].length).to be > 0
        end

        describe 'Forbidden attempt to create discount' do
          it 'Plan Discounts Exhausted' do
            c = Client.find(client._id)
            c.client_plans.first.num_of_discounts_left = 0
            c.save!
            post :create, client_id: client._id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = JSON.parse response.body, symbolize_names: true
            expect(response_body[:errors].length).to eql 1
            expect(response_body[:errors][0]).to eql 'You have exhausted your plan discounts, you need to purchase a new plan'
            c.reload
            expect(c.client_plans).to be_empty
          end

          it 'Does not have plan' do
            jwt_validate_token raw_client
            post :create, client_id: raw_client._id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = JSON.parse response.body, symbolize_names: true
            expect(response_body[:errors].length).to eql 1
            expect(response_body[:errors][0]).to eql 'You need a plan to create a discount'
          end
        end
      end

      describe 'Get all available discounts' do
        it 'user should get all available discounts base on his/her subscriptions' do
          users.map do |user|
            jwt_validate_token user
            get :index, {}, format: :json
            expect(response.status).to eql 200
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:discounts].length).to be > 0
            response_body[:discounts].each do |client|
              expect(client[:discounts].length).to be > 0
              expect(client[:addresses].length).to be > 0
              expect(client[:locations].length).to be > 0
              client_categories = client[:categories].map { |c| c[:name] }
              user_subscriptions = user.categories.map { |c| c[:name] }
              expect(client_categories & user_subscriptions).not_to be_empty
            end
          end
        end

        it 'should get all available discounts if doesn\'t have subscriptions' do
          raw_users.map do |user|
            jwt_validate_token user
            get :index, {}, format: :json
            expect(response.status).to eql 200
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:discounts].length).to be > 0
            response_body[:discounts].each do |client|
              expect(client[:discounts].length).to be > 0
              expect(client[:addresses].length).to be > 0
              expect(client[:locations].length).to be > 0
              client_categories = client[:categories].map { |c| c[:name] }
              user_subscriptions = user.categories.map { |c| c[:name] }
              expect(client_categories & user_subscriptions).to be_empty
            end
          end
        end
      end

      describe 'User Likes a discount' do
        it 'should get a secret key to redeem a discount' do
          users.map do |user|
            jwt_validate_token user
            clients.each do |client|
              discount = Client.find(client._id).discounts.sample
              post :like,
                   id: user._id.to_s,
                   client_id:  client._id.to_s,
                   discount_id: discount._id.to_s
              expect(response.status).to eql 200
              u = User.find(user._id)
              expect(u.discounts).to include discount
              expect(u.client_ids).to include client._id.to_s
            end
          end
        end
      end

      describe 'Client Get all his/her discounts' do
        it 'should return all client discounts' do
          clients.each do |client|
            jwt_validate_token client
            get :client_discounts, client_id: client._id
            expect(response.status).to eql 200
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:discounts].length).to be == 5
          end
        end
      end
    end
  end
end
