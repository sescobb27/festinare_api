require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe DiscountsController, type: :controller  do
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
        mock_token
      end

      let(:client) do
        FactoryGirl.create :client_with_discounts
      end

      let(:customer) do
        FactoryGirl.create :customer_with_subscriptions
      end

      let(:raw_customer) do
        FactoryGirl.create :customer
      end

      describe 'POST #create' do
        let(:raw_client) do
          FactoryGirl.create :client
        end

        let(:client_with_plan) do
          FactoryGirl.create :client_with_plan
        end

        let(:discount) { FactoryGirl.attributes_for(:discount) }

        it 'should be able to create a discount' do
          jwt_validate_token client_with_plan
          post :create, client_id: client_with_plan.id, discount: discount.to_hash
          expect(response.status).to eql 200

          client_discount = Client.joins(:discounts).find(client_with_plan.id).discounts.first

          expect(client_discount.discount_rate).to eql discount[:discount_rate]
          expect(client_discount.title).to eql discount[:title]
          expect(client_discount.secret_key).to eql discount[:secret_key]
          expect(client_discount.status).to eql discount[:status]
          expect(client_discount.duration).to eql discount[:duration]
          expect(client_discount.hashtags).to eql discount[:hashtags]

          c = Client.unscoped.find(client_with_plan.id)
          clients_plan = c.clients_plans.first
          plan = client_with_plan.plans.first
          expect(clients_plan.num_of_discounts_left).to eql plan.num_of_discounts - 1
        end

        it 'should not be able to create a discount' do
          jwt_validate_token client_with_plan
          discount[:duration] = [0, 15, 25, 35, 65, 95, 125].sample
          post :create, client_id: client_with_plan.id, discount: discount.to_hash
          expect(response.status).to eql 400
          response_body = json_response
          expect(response_body[:errors].length).to be > 0
        end

        it 'should create discount it has at least one valid plan' do
          jwt_validate_token client
          plans = Plan.all.offset(1).sample(2)
          ClientsPlan.create_from_plan client, plans[0] do |clients_plan|
            clients_plan.num_of_discounts_left = 0
          end
          ClientsPlan.create_from_plan client, plans[1]

          post :create, client_id: client.id, discount: discount.to_hash
          expect(response.status).to eql 200

          first_valid_plan = Client
                             .joins(:clients_plans)
                             .merge(ClientsPlan.with_discounts)
                             .find(client.id)
                             .clients_plans.with_discounts
                             .first
          expect(first_valid_plan.num_of_discounts_left).to(
            eql plans[1].num_of_discounts - 1
          )
        end

        describe 'Forbidden attempt to create discount' do
          it 'Plan Discounts Exhausted' do
            jwt_validate_token client
            plan = Plan.all.offset(1).sample
            ClientsPlan.create_from_plan client, plan do |clients_plan|
              clients_plan.num_of_discounts_left = 0
            end
            post :create, client_id: client.id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = json_response
            expect(response_body[:errors].length).to eql 1
            expect(response_body[:errors][0]).to(
              eql "You don't have a plan or You have exhausted all your plan discounts, you need to purchase a new plan"
            )
            c = Client.joins(:clients_plans).find(client.id)
            expect(c.clients_plans.with_discounts).to be_empty
          end

          it 'Does not have plan' do
            jwt_validate_token raw_client
            post :create, client_id: raw_client.id, discount: discount.to_hash
            expect(response.status).to eql 403
            response_body = json_response
            expect(response_body[:errors].length).to eql 1
            expect(response_body[:errors][0]).to(
              eql "You don't have a plan or You have exhausted all your plan discounts, you need to purchase a new plan"
            )
          end
        end
      end

      describe 'GET #index' do
        before do
          FactoryGirl.create_list :client_with_discounts, 50
        end

        it 'customer should get all available discounts base on subscriptions' do
          jwt_validate_token customer
          get :index, {}, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:discounts].length).to eql 20
          response_body[:discounts].each do |client|
            expect(client[:discounts].length).to be > 0
            client[:discounts].each do |discount|
              expect(discount.keys).not_to include :secret_key
            end
            expect(client[:addresses].length).to be > 0
            expect(client[:categories] & customer.categories).not_to be_empty
          end
        end

        it 'should get all available discounts if doesn\'t have likes' do
          jwt_validate_token raw_customer
          get :index, {}, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:discounts].length).to eql 20
          response_body[:discounts].each do |client|
            expect(client[:discounts].length).to be > 0
            client[:discounts].each do |discount|
              expect(discount.keys).not_to include :secret_key
            end
            expect(client[:addresses].length).to be > 0
            expect(client[:categories] & raw_customer.categories).to be_empty
          end
        end

        it 'should return 50 available discounts' do
          jwt_validate_token customer
          get :index, limit: 50, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:discounts].length).to eql 50
        end
      end

      describe 'POST #like' do
        before do
          FactoryGirl.create_list :client_with_discounts, 50
        end

        it 'should get a qrcode to redeem a discount' do
          jwt_validate_token customer
          discount = Client.includes(:discounts).find(client.id).discounts.sample
          post :like,
               id: customer.id,
               client_id:  client.id,
               discount_id: discount.id
          expect(response.status).to eql 200
          u = Customer.includes(:discounts).find(customer.id)
          expect(u.discounts).to include discount
          expect(response.content_type).to eql 'image/png'
          expect(response.body).not_to include discount.secret_key
          expect(response.body.length).to be > 0
        end

        it 'should not get a liked discount' do
          jwt_validate_token customer
          # fetch discounts
          get :index, {}, format: :json
          response_body = json_response
          expect(response_body[:discounts].length).to eql 20
          client = response_body[:discounts].sample
          discount = client[:discounts].sample

          # like one discount
          post :like,
               id: customer.id,
               client_id:  client[:id],
               discount_id: discount[:id]
          expect(response.status).to eql 200
          u = Customer.includes(:discounts).find(customer.id)
          discount_ids = u.discounts.map do |u_discount|
            u_discount.id
          end
          expect(discount_ids).to include discount[:id]

          # fetch the same discounts and the liked discount should not
          # be there
          get :index, {}, format: :json
          response_body = json_response
          expect(response_body[:discounts].length).to eql 20

          response_body[:discounts].each do |c|
            c_discount_ids = c[:discounts].map do |c_discount|
              c_discount[:id]
            end
            expect(c_discount_ids).not_to include discount[:id]
          end
        end

        it 'should not like a expired discount' do
          jwt_validate_token customer

          get :index, {}, format: :json
          response_body = json_response
          expect(response_body[:discounts].length).to eql 20
          client = response_body[:discounts].sample
          sample_discount = client[:discounts].sample

          discount = Discount.find sample_discount[:id]
          # invalidate a discount by time
          discount.created_at = (discount.created_at - (discount.duration * 60).seconds - 1.minute)
          discount.save!

          post :like,
               id: customer.id,
               client_id:  client[:id],
               discount_id: sample_discount[:id]
          response_body = json_response
          expect(response.status).to eql 400
          expect(response_body[:errors].first).to eql 'Discount expired'
        end
      end

      describe 'GET #discounts' do
        it 'should return all client discounts' do
          jwt_validate_token client
          get :discounts, client_id: client.id
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:discounts].length).to be == 5
        end
      end
    end
  end
end
