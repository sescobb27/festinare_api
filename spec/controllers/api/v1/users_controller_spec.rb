require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe UsersController, type: :controller  do
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
        expect(post: "http://#{request.host}/api/v1/users").to(
          route_to(
            controller: 'api/v1/users',
            action: 'create',
            format: :json
          )
        )

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'

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

        it 'should have mobile' do
          User.new(@user).save
          user = User.find_by username: @user[:username]
          expect(user._id.to_s).not_to eql ''
          mobile = FactoryGirl.attributes_for :mobile
          jwt_validate_token user
          post :mobile, id: user._id, user: { mobile: mobile }, format: :json
          expect(response.status).to eql 200
          expect(mobile[:token]).not_to be_empty
          expect(mobile[:token]).to eql User.find(user._id).mobile.token
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

      describe 'User Update' do
        let(:user) do
          FactoryGirl.create :user
        end

        it 'should add given categories to user' do
          jwt_validate_token user
          put(:update, {
                id: user._id,
                user: {
                  categories: [
                    { name: 'Bar', description: '', status: true },
                    { name: 'Restaurant', description: '', status: true }
                  ]
                }
              }, format: :json)
          expect(response.status).to eql 200
          u = User.find user._id
          user_categories = u.categories.map(&:name)
          expect(user_categories).to include('Bar')
          expect(user_categories).to include('Restaurant')
        end

        it 'should delete given categories from user' do
          user.categories.push(
            Category.new(name: 'Bar'),
            Category.new(name: 'Restaurant')
          )
          jwt_validate_token user
          put(:update, {
                id: user._id,
                user: {
                  categories: [
                    { name: 'Bar', description: '', status: false },
                    { name: 'Restaurant', description: '', status: false }
                  ]
                }
              }, format: :json)
          expect(response.status).to eql 200
          u = User.find user._id
          user_categories = u.categories.map(&:name)
          expect(user_categories).not_to include('Bar')
          expect(user_categories).not_to include('Restaurant')
        end

        it 'should delete/add given categories from/to user' do
          user.categories.push(
            Category.new(name: 'Restaurant')
          )
          jwt_validate_token user
          put(:update, {
                id: user._id,
                user: {
                  categories: [
                    { name: 'Bar', description: '', status: true },
                    { name: 'Restaurant', description: '', status: false }
                  ]
                }
              }, format: :json)
          expect(response.status).to eql 200
          u = User.find user._id
          user_categories = u.categories.map(&:name)
          expect(user_categories).to include('Bar')
          expect(user_categories).not_to include('Restaurant')
        end
      end

      describe 'Get Liked Clients' do
        let :client do
          FactoryGirl.create :client_with_discounts
        end

        it 'users should get all liked clients' do
          user = FactoryGirl.create :user_with_subscriptions
          jwt_validate_token user
          user.add_to_set client_ids: client._id.to_s

          get :likes, id: user._id.to_s, format: :json
          expect(response.status).to eql 200
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:clients].length).to eql 1
          expect(response_body[:clients].first[:email]).to eql nil
          expect(response_body[:clients].first[:name]).to eql client.name
        end
      end
    end
  end
end
