require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe UsersController, :type => :controller  do
      def jwt_validate_token user
        @auth_token = allow(JWT::AuthToken).to(
          receive(:validate_token).and_return({
            _id: user._id,
            username: user.username,
            email: user.email
          })
        )
      end
      before do
        request.host = 'api.example.com'
        expect({:post => "http://#{request.host}/v1/users"}).to(
          route_to( controller: 'api/v1/users',
                    action: 'create',
                    subdomain: 'api',
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
          post :mobile, { id: user._id, user: { mobile: mobile } }, format: :json
          expect(response.status).to eql 200
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
        let!(:users) {
          users = (1..10).map { FactoryGirl.attributes_for :user_with_subscriptions }
          User.create users
        }
        it 'should add given categories to user' do
          users.each do |user|
            jwt_validate_token user
            put(:update, {
                            id: user._id, user: {
                              categories: [
                                { status: true, name: 'Bar', description: '' },
                                { status: true, name: 'Restaurant', description: '' }
                              ]
                            }
                          }, format: :json)
            expect(response.status).to eql 200
            u = User.find user._id
            user_categories = u.categories.map(&:name)
            expect(user_categories).to include('Bar')
            expect(user_categories).to include('Restaurant')
          end
        end

        it 'should delete given categories from user' do
          users.each do |user|
            jwt_validate_token user
            put(:update, {
                            id: user._id, user: {
                              categories: [
                                { status: false, name: 'Bar', description: '' },
                                { status: false, name: 'Restaurant', description: '' }
                              ]
                            }
                          }, format: :json)
            expect(response.status).to eql 200
            u = User.find user._id
            user_categories = u.categories.map(&:name)
            expect(user_categories).not_to include('Bar')
            expect(user_categories).not_to include('Restaurant')
          end
        end

        it 'should delete/add given categories from/to user' do
          users.each do |user|
            jwt_validate_token user
            put(:update, {
                            id: user._id, user: {
                              categories: [
                                { status: true, name: 'Bar', description: '' },
                                { status: false, name: 'Restaurant', description: '' }
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
      end
    end
  end
end
