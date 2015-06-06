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

      let(:client) do
        FactoryGirl.create :client_with_discounts
      end

      let(:user) do
        FactoryGirl.create :user_with_subscriptions
      end

      let(:raw_user) do
        FactoryGirl.create :user
      end

      describe 'Create Discount' do
        let(:raw_client) do
          FactoryGirl.create :client
        end

        let(:client) do
          FactoryGirl.create :client_with_plan
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

          c = Client.unscoped.find(client._id)
          plan = c.client_plans.first
          expect(plan.num_of_discounts_left).to eql plan.num_of_discounts - 1

          Cache::RedisCache.instance do |redis|
            len = redis.llen('discounts')
            expect(len).to be > 0
            obj = redis.lrange('discounts', len - 1, len - 1)[0]
            cache_discount = JSON.parse(obj)
            expect(cache_discount['discount']['title']).to(
              eql client_discount.title
            )
            expect(cache_discount['discount']['_id']['$oid']).to(
              eql client_discount._id.to_s
            )
          end
        end

        it 'should not be able to create a discount' do
          discount[:duration] = [0, 15, 25, 35, 65, 95, 125].sample
          post :create, client_id: client._id, discount: discount.to_hash
          expect(response.status).to eql 400
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response_body[:errors].length).to be > 0
        end

        it 'should create discount it has at least one valid plan' do
          plans = Plan.all.offset(1).sample(2).map(&:to_client_plan)
          plans.first.num_of_discounts_left = 0
          client.client_plans = plans
          client.save
          post :create, client_id: client._id, discount: discount.to_hash
          expect(response.status).to eql 200

          client.reload
          first_valid_plan = client.client_plans.with_discounts.first
          expect(first_valid_plan.num_of_discounts_left).to(
            eql plans[1].num_of_discounts_left - 1
          )
        end

        describe 'Forbidden attempt to create discount' do
          it 'Plan Discounts Exhausted' do
            c = Client.find(client._id)
            c.client_plans.first.num_of_discounts_left = 0
            c.save!
            post :create, client_id: client._id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = JSON.parse response.body, symbolize_names: true
            expect(response_body[:errors].length).to eql 2
            expect(response_body[:errors][0]).to(
              eql 'You need a plan to create a discount'
            )
            # rubocop:disable Metrics/LineLength
            expect(response_body[:errors][1]).to(
              eql 'You have exhausted your plan discounts, you need to purchase a new plan'
            )
            # rubocop:enable Metrics/LineLength
            c.reload
            expect(c.client_plans.with_discounts).to be_empty
          end

          it 'Does not have plan' do
            jwt_validate_token raw_client
            post :create, client_id: raw_client._id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = JSON.parse response.body, symbolize_names: true
            expect(response_body[:errors].length).to eql 2
            expect(response_body[:errors][0]).to(
              eql 'You need a plan to create a discount'
            )
            # rubocop:disable Metrics/LineLength
            expect(response_body[:errors][1]).to(
              eql 'You have exhausted your plan discounts, you need to purchase a new plan'
            )
            # rubocop:enable Metrics/LineLength
          end
        end
      end

      describe 'Get all available discounts' do
        before do
          Client.create(
            (1..50).map { FactoryGirl.attributes_for :client_with_discounts }
          )
        end
        it 'user should get all available discounts base on subscriptions' do
          jwt_validate_token user
          get :index, {}, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:discounts].length).to eql 20
          response_body[:discounts].each do |client|
            expect(client[:discounts].length).to be > 0
            expect(client[:addresses].length).to be > 0
            expect(client[:locations].length).to be > 0
            client_categories = client[:categories].map { |c| c[:name] }
            user_subscriptions = user.categories.map { |c| c[:name] }
            expect(client_categories & user_subscriptions).not_to be_empty
          end
        end

        it 'should get all available discounts if doesn\'t have likes' do
          jwt_validate_token raw_user
          get :index, {}, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:discounts].length).to eql 20
          response_body[:discounts].each do |client|
            expect(client[:discounts].length).to be > 0
            expect(client[:addresses].length).to be > 0
            expect(client[:locations].length).to be > 0
            client_categories = client[:categories].map { |c| c[:name] }
            user_subscriptions = raw_user.categories.map { |c| c[:name] }
            expect(client_categories & user_subscriptions).to be_empty
          end
        end

        it 'should return 50 available discounts' do
          jwt_validate_token user
          get :index, limit: 50, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:discounts].length).to eql 50
        end
      end

      describe 'User Likes a discount' do
        it 'should get a secret key to redeem a discount' do
          jwt_validate_token user
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

        it 'should not get a liked discount' do
          jwt_validate_token user
          # fetch discounts
          get :index, {}, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:discounts].length).to eql 20
          client = response_body[:discounts].sample
          discount = client[:discounts].sample

          # like one discount
          post :like,
               id: user._id.to_s,
               client_id:  client[:_id],
               discount_id: discount[:_id]
          expect(response.status).to eql 200
          u = User.find(user._id)
          discount_ids = u.discounts.map do |u_discount|
            u_discount._id.to_s
          end
          expect(discount_ids).to include discount[:_id]
          expect(u.client_ids).to include client[:_id]

          # fetch the same discounts and the liked discount should not
          # be there
          get :index, {}, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:discounts].length).to eql 20

          response_body[:discounts].each do |c|
            c_discount_ids = c[:discounts].map do |c_discount|
              c_discount[:_id]
            end
            expect(c_discount_ids).not_to include discount[:_id]
          end
        end
      end

      describe 'Client Get all his/her discounts' do
        it 'should return all client discounts' do
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
