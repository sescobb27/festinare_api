require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe LocationsController, type: :controller  do
      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/customers/id/locations").to(
          route_to(controller: 'api/v1/locations', action: 'create', format: :json, id: 'id')
        )

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
        mock_token
      end

      let(:locations) { FactoryGirl.create_list :location, 10 }
      let(:location) { FactoryGirl.attributes_for :location }
      let!(:customer) { FactoryGirl.create :customer }
      describe 'GET #index' do
        it 'should not get customer\'s locations if not logged in' do
          get :index, id: customer.id
          expect(response.status).to eql 401
        end

        it 'should get customer\'s locations' do
          jwt_validate_token customer
          customer.locations = locations
          customer.save
          get :index, id: customer.id, limit: 10
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:locations].length).to eql 10
        end
      end

      describe 'POST #create' do
        it 'should not add locations to a customer if not logged in' do
          post :create, id: customer.id, location: location
        end

        it 'should add locations' do
          jwt_validate_token customer
          post :create, id: customer.id, location: location
          expect(response.status).to eql 201
          c_locations = Customer.includes(:locations).find(customer.id).locations
          expect(c_locations.length).to eql 1
          expect(c_locations.map(&:address)).to include location[:address]
        end
      end
    end
  end
end
