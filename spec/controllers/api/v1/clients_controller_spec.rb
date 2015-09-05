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
          }, id: client.id, format: :json
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
          put :update, client: {
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

        it 'should be able to update attributes' do
          # jwt_validate_token client
          # pending "TODO #{__FILE__}"
        end
      end
    end
  end
end
