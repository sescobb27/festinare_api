require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe UsersController, :type => :controller  do
      before do
        request.host = 'api.example.com'
        expect({:post => "http://#{request.host}/v1/users"}).to(
          route_to( controller: 'api/v1/users',
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

      describe 'Create User' do
        before(:each) do
          @user = FactoryGirl.attributes_for :user
        end

        it 'should return a token' do
          post :create, subdomain: 'api', user: @user, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response.status).to eql 200
          expect(response_body[:token]).to eql 'mysecretkey'
        end

        it 'should return status bad request for short passwords' do
          @user['password'] = 'qwerty'
          post :create, subdomain: 'api', user: @user, format: :json
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response.status).to eql 400
          expect(response_body[:errors].length).to eql 1
        end
      end

      describe 'User Login' do
        before do
          @user = FactoryGirl.attributes_for :user
          User.create @user
        end
        before(:each) do
          expect(User.count).to be >= 1
        end

        it 'should be successfully logged in' do
          post :login, user: @user, format: :json
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response.status).to eql 200
          expect(response_body[:token]).to eql 'mysecretkey'
        end

        it 'should return status unauthorized if password not match' do
          @user['password'] = 'wrong_password'
          post :login, user: @user, format: :json
          expect(response.status).to eql 401
          expect(response.body).to eql ''
        end

        it 'should return status unauthorized if username not match' do
          @user['username'] = 'wrong_username'
          post :login, user: @user, format: :json
          expect(response.status).to eql 401
          expect(response.body).to eql ''
        end
      end
    end
  end
end
