require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe ClientsController, :type => :controller  do

      before do
        request.host = 'api.example.com'
        expect({:post => "http://#{request.host}/v1/clients"}).to(
          route_to( controller: 'api/v1/clients',
                    action: 'create',
                    subdomain: 'api',
                    format: :json
                  )
        )

        # token expectations
        @auth_token = allow(JWT::AuthToken).to(
          receive(:make_token).and_return('mysecretkey')
        )
        expect(JWT::AuthToken.make_token({}, 3600)).to eq('mysecretkey')
      end

      describe 'Create Client' do

        let!(:client) { FactoryGirl.attributes_for(:client) }

        it 'should return a token' do
          post :create, subdomain: 'api', client: client, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response.status).to eql 200
          expect(response_body[:token]).to eql 'mysecretkey'
        end

        it 'should return status bad request for short passwords' do
          client['password'] = 'qwerty'
          post :create, subdomain: 'api', client: client, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response.status).to eql 400
          expect(response_body[:errors].length).to eql 1
        end
      end

      describe 'Client Login' do

        let!(:client) {
          client_attr = FactoryGirl.attributes_for :client
          Client.create client_attr
          client_attr
        }

        it 'should be successfully logged in' do
          post :login, client: client, format: :json
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response.status).to eql 200
          expect(response_body[:token]).to eql 'mysecretkey'
        end

        it 'should return status unauthorized if password not match' do
          client['password'] = 'wrong_password'
          post :login, client: client, format: :json
          expect(response.status).to eql 401
          expect(response.body).to eql ''
        end

        it 'should return status unauthorized if username not match' do
          client['username'] = 'wrong_username'
          post :login, client: client, format: :json
          expect(response.status).to eql 401
          expect(response.body).to eql ''
        end
      end

    end
  end
end
