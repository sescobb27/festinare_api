require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe CustomersController, type: :controller  do
      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/customers").to(
          route_to(
            controller: 'api/v1/customers',
            action: 'create',
            format: :json
          )
        )

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
        mock_token
      end

      it_behaves_like 'User', :customer

      describe 'POST #create' do
        before(:each) do
          @customer = FactoryGirl.attributes_for :customer
        end

        it 'should have mobile' do
          Customer.new(@customer).save
          customer = Customer.find_by username: @customer[:username]
          expect(customer.id.to_s).not_to eql ''
          mobile = FactoryGirl.attributes_for :mobile
          jwt_validate_token customer
          post :mobile, id: customer.id, customer: { mobile: mobile }, format: :json
          expect(response.status).to eql 200
          expect(mobile[:token]).not_to be_empty
          expect(mobile[:token]).to eql Customer.joins(:mobiles).find(customer.id).mobiles.first.token
        end
      end

      describe 'PUT #update' do
        let(:customer) do
          FactoryGirl.create :customer
        end

        it 'should add given categories to customer' do
          jwt_validate_token customer
          put(:add_category, {
                id: customer.id,
                customer: { categories: ['Bar', 'Restaurant'] }
              }, format: :json)
          expect(response.status).to eql 201
          u = Customer.find customer.id
          expect(u.categories).to include('Bar')
          expect(u.categories).to include('Restaurant')
        end

        it 'should delete given categories from customer' do
          customer.categories = ['Bar', 'Restaurant']
          customer.save
          jwt_validate_token customer
          delete(:delete_category, {
                id: customer.id,
                customer: { categories: ['Bar', 'Restaurant'] }
              }, format: :json)
          expect(response.status).to eql 200
          u = Customer.find customer.id
          expect(u.categories).not_to include('Bar')
          expect(u.categories).not_to include('Restaurant')
        end
      end

      describe 'GET #likes' do
        let :client do
          FactoryGirl.create :client_with_discounts
        end

        it 'customers should get all liked clients' do
          customer = FactoryGirl.create :customer_with_subscriptions
          jwt_validate_token customer
          customer.discounts << client.discounts.sample

          get :likes, id: customer.id, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:clients].length).to eql 1
          expect(response_body[:clients].first[:email]).to eql nil
          expect(response_body[:clients].first[:name]).to eql client.name
        end
      end
    end
  end
end
