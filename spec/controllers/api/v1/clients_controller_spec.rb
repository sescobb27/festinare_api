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

      describe 'POST #create' do
        let(:client) { FactoryGirl.attributes_for(:client) }

        it 'should return a token' do
          post :create, client: client, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:token]).to eql 'mysecretkey'
        end

        it 'should return status bad request for short passwords' do
          client['password'] = 'qwerty'
          post :create, client: client, format: :json
          expect(response.status).to eql 400
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:errors].length).to eql 1
        end
      end

      describe 'POST #login' do
        let(:client) do
          client_attr = FactoryGirl.attributes_for :client
          Client.create! client_attr
          client_attr
        end

        it 'should be successfully logged in' do
          post :login, client: client, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response_body[:token]).to eql 'mysecretkey'
          cli = Client.find_by username: client[:username]
          expect(cli.token).to include client[:token][0]
        end

        it 'should return status unauthorized if password not match' do
          client['password'] = 'wrong_password'
          post :login, client: client, format: :json
          expect(response.status).to eql 400
          expect(response.body).to eql ''
        end

        it 'should return status unauthorized if username not match' do
          client['username'] = 'wrong_username'
          post :login, client: client, format: :json
          expect(response.status).to eql 400
          expect(response.body).to eql ''
        end
      end

      describe 'POST #logout' do
        let(:client) do
          client_attr = FactoryGirl.attributes_for :client
          client_attr[:token] = ['mysecretkey']
          Client.create client_attr
        end

        it 'client should be logged out and token should be removed' do
          jwt_validate_token client
          post :logout, format: :json
          expect(response.status).to eql 200
          cli = Client.find client._id
          expect(cli.token).not_to include 'mysecretkey'
        end

        it 'client response code should be unauthorized' do
          jwt_validate_token client
          post :logout, format: :json
          expect(response.status).to eql 200
          get :me, client: client, format: :json
          expect(response.status).to eql 401
          cli = Client.find client._id
          expect(cli.token).not_to include 'mysecretkey'
        end
      end

      describe 'GET #me' do
        let(:client) do
          client_attr = FactoryGirl.attributes_for :client
          client_attr[:token] = ['mysecretkey']
          Client.create client_attr
        end
        it 'should return client attribute' do
          jwt_validate_token client
          get :me, client: client, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:client][:_id]).to eql client._id.to_s
          expect(response_body[:client][:email]).to eql client.email
        end
        it 'client response code should be unauthorized' do
          client.pull token: 'mysecretkey'
          jwt_validate_token client
          get :me, client: client, format: :json
          expect(response.status).to eql 401
        end
      end

      describe 'PUT #update' do
        let(:client) do
          FactoryGirl.create :client
        end

        it 'should be able to update password' do
          jwt_validate_token client
          put :update, client: {
            password: {
              current_password: client.password,
              password: 'passwordpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client._id.to_s, format: :json
          puts response.body
          expect(response.status).to eql 200
          client.reload
          expect(client.valid_password? 'passwordpassword').to be true
          expect(client.valid_password? 'qwertyqwerty').to be false
        end

        it 'should not be able to update password (password != password_confirmation)' do
          jwt_validate_token client
          put :update, client: {
            password: {
              current_password: client.password,
              password: 'anotherpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client._id.to_s, format: :json
          expect(response.status).to eql 403
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:errors]).to include 'Password confirmation doesn\'t match Password'
          client.reload
          expect(client.valid_password? 'anotherpassword').to be false
          expect(client.valid_password? 'qwertyqwerty').to be true
        end

        it 'should not be able to update password (invalid current_password)' do
          jwt_validate_token client
          put :update, client: {
            password: {
              current_password: 'invalid_current_password',
              password: 'passwordpassword',
              password_confirmation: 'passwordpassword'
            }
          }, id: client._id.to_s, format: :json
          expect(response.status).to eql 403
          client.reload
          expect(client.valid_password? 'passwordpassword').to be false
          expect(client.valid_password? 'qwertyqwerty').to be true
        end

        it 'should be able to update attributes' do
          # jwt_validate_token client
          # pending "TODO #{__FILE__}"
        end
      end
    end
  end
end
