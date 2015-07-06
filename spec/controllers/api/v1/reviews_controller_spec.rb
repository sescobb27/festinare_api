require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe ReviewsController, type: :controller do
      def jwt_validate_token(user)
        @auth_token = allow(JWT::AuthToken).to(
          receive(:validate_token).and_return(
            _id: user[:_id],
            username: user[:username],
            email: user[:email]
          )
        )
      end

      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/users/1/reviews").to(
          route_to(
            controller: 'api/v1/reviews',
            action: 'create',
            user_id: '1',
            format: :json
          )
        )

        # token expectations
        @auth_token = allow(JWT::AuthToken).to(
          receive(:make_token).and_return('mysecretkey')
        )
        expect(JWT::AuthToken.make_token({}, 3600)).to eq('mysecretkey')

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
      end

      describe 'Client Review' do
        let :client do
          FactoryGirl.create :client_with_discounts
        end

        it 'should not be able to review a client' do
          user = FactoryGirl.create :user_with_subscriptions
          jwt_validate_token user
          post :create,
               user: { client_id: client._id.to_s, rate: rand(1..5), feedback: 'feedback' },
               user_id: user._id.to_s,
               format: :json
          expect(response.status).to eql 403
        end

        it 'should review a client' do
          rates = (1..3).map { rand(1..5) }
          3.times do |step|
            user = FactoryGirl.create :user_with_subscriptions
            jwt_validate_token user
            user.add_to_set client_ids: client._id.to_s
            post :create,
                 user: { client_id: client._id.to_s, rate: rates[step], feedback: "feedback#{step}" },
                 user_id: user._id.to_s,
                 format: :json
            expect(response.status).to eql 201
          end
          client_with_reviews = Client.includes(:reviews).find client._id
          expect(client_with_reviews.reviews.length).to eql(3)

          client_rates = client_with_reviews.reviews.map(&:rate)
          expect(client_rates.sum.fdiv 3).to eql rates.sum.fdiv(3)
          expect(client_with_reviews.reviews.map(&:feedback)).to include 'feedback0'
        end

        it 'should not be able to review a client twice' do
          user = FactoryGirl.create :user_with_subscriptions
          rate = rand(1..5)
          jwt_validate_token user
          user.add_to_set client_ids: client._id.to_s
          # first review
          post :create,
               user: { client_id: client._id.to_s, rate: rate, feedback: 'feedback' },
               user_id: user._id.to_s,
               format: :json
          expect(response.status).to eql 201
          user = User.includes(:reviews).find user._id
          expect(user.reviews.map(&:client_id)).to include client._id

          # second review
          post :create,
               user: { client_id: client._id.to_s, rate: rate, feedback: 'feedback' },
               user_id: user._id.to_s,
               format: :json
          expect(response.status).to eql 405
        end
      end
    end
  end
end
