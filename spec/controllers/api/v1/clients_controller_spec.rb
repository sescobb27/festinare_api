require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe ClientsController, type: :controller  do
      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/clients").to(
          route_to(
            controller: 'api/v1/clients',
            action: 'create',
            format: :json
          )
        )

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
        mock_token
      end

      it_behaves_like 'User', :client

      describe 'PUT #password_update' do
        let(:client) do
          FactoryGirl.create :client
        end

        it 'should be able to update password' do
          jwt_validate_token client
          put :password_update, client: {
            password: {
              current_password: client.password,
              password: 'passwordpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client.id, format: :json
          expect(response.status).to eql 200
          client.reload
          expect(client.valid_password? 'passwordpassword').to be true
          expect(client.valid_password? 'qwertyqwerty').to be false
        end

        it 'should not be able to update password (password != password_confirmation)' do
          jwt_validate_token client
          put :password_update, client: {
            password: {
              current_password: client.password,
              password: 'anotherpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client.id, format: :json
          expect(response.status).to eql 403
          response_body = json_response
          expect(response_body[:errors]).to include 'Password confirmation doesn\'t match Password'
          client.reload
          expect(client.valid_password? 'anotherpassword').to be false
          expect(client.valid_password? 'qwertyqwerty').to be true
        end

        it 'should not be able to update password (invalid current_password)' do
          jwt_validate_token client
          put :password_update, client: {
            password: {
              current_password: 'invalid_current_password',
              password: 'passwordpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client.id, format: :json
          expect(response.status).to eql 403
          response_body = json_response
          expect(response_body[:errors]).to include 'Current password is invalid'
          client.reload
          expect(client.valid_password? 'passwordpassword').to be false
          expect(client.valid_password? 'qwertyqwerty').to be true
        end
      end

      describe 'PUT #update' do
        let(:client) do
          FactoryGirl.create :client
        end

        it 'should be able to update attributes' do
          jwt_validate_token client
          image_url = FFaker::Internet.http_url
          put :update, client: {
            name: 'Client\'s New Name',
            image_url: image_url,
            categories: User::CATEGORIES
          }, id: client.id, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:client][:categories]).to eql User::CATEGORIES
          expect(response_body[:client][:name]).to eql 'Client\'s New Name'
          expect(response_body[:client][:image_url]).to eql image_url
        end

        it 'should be able to add addresses' do
          jwt_validate_token client
          new_address = FFaker::Address.street_address
          put :update, client: {
            addresses: client.addresses + [new_address]
          }, id: client.id, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:client][:addresses].length).to eql 6
          expect(response_body[:client][:addresses]).to eql client.addresses + [new_address]
        end

        it 'should be able to delete address from addresses' do
          jwt_validate_token client
          addresses = client.addresses.sample(2)
          put :update, client: {
            addresses: addresses
          }, id: client.id, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:client][:addresses].length).to eql 2
          expect(response_body[:client][:addresses]).to eql addresses
        end
      end

      describe 'GET #index' do
        let!(:clients) { FactoryGirl.create_list :client, 20 }
        it 'should get 20 clients' do
          get :index, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:clients].length).to eql 20
          response_body[:clients].each do |client|
            expect(client[:password]).to be_blank
            expect(client[:email]).to be_blank
            expect(client[:tokens]).to be_blank
            expect(client[:username]).to be_blank
            expect(client[:encrypted_password]).to be_blank
          end
          names = response_body[:clients].map { |client| client[:name] }
          created_names = clients.map(&:name)
          expect(names).to eql created_names
        end
        it 'should get 5 clients' do
          get :index, limit: 5, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:clients].length).to eql 5
        end
      end
    end
  end
end
