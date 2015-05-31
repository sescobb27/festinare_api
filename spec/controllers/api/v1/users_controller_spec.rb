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
        let(:users) do
          users = (1..10).map do
            FactoryGirl.attributes_for :user
          end
          User.create users
        end

        it 'should add given categories to user' do
          users.each do |user|
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
        end

        it 'should delete given categories from user' do
          users.each do |user|
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
        end

        it 'should delete/add given categories from/to user' do
          users.each do |user|
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
      end

      describe 'User Review a Client' do
        let :client do
          FactoryGirl.create :client_with_discounts
        end

        it 'shouldn\'t be able to review a client' do
          rates = (1..10).map { rand(1..5) }
          10.times do |step|
            user = FactoryGirl.create :user_with_subscriptions
            jwt_validate_token user
            post :review,
                 user: { rate: rates[step], feedback: "feedback#{step}" },
                 id: user._id.to_s,
                 client_id: client._id.to_s,
                 format: :json
            expect(response.status).to eql 403
          end
        end
        it 'should review a client and its avg should change' do
          rates = (1..10).map { rand(1..5) }
          c_client = Client.find client._id.to_s
          10.times do |step|
            user = FactoryGirl.create :user_with_subscriptions
            jwt_validate_token user
            user.push client_ids: client._id.to_s
            post :review,
                 user: { rate: rates[step], feedback: "feedback#{step}" },
                 id: user._id.to_s,
                 client_id: client._id.to_s,
                 format: :json
            expect(response.status).to eql 200
            c_client.reload
            expect(c_client.rates.length).to eql(step + 1)
            expect(c_client.avg_rate).to eql rates[0..step].sum.fdiv(step + 1)
            expect(c_client.feedback[step]).to eql "feedback#{step}"
          end
          expect(c_client.avg_rate).to eql rates.sum.fdiv 10
        end
      end
    end
  end
end
