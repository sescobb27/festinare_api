require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe ReviewsController, type: :controller do
      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/customers/1/reviews").to(
          route_to(
            controller: 'api/v1/reviews',
            action: 'create',
            customer_id: '1',
            format: :json
          )
        )

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
        mock_token
      end

      let :client do
        FactoryGirl.create :client_with_discounts
      end
      describe 'POST #create' do
        it 'should not be able to review a discount' do
          customer = FactoryGirl.create :customer_with_subscriptions
          jwt_validate_token customer
          post :create,
               review: { discount_id: client.discounts.first, rate: rand(1..5), feedback: 'feedback' },
               customer_id: customer.id,
               format: :json
          expect(response.status).to eql 403
        end

        it 'should review a discount' do
          rates = (1..3).map { rand(1..5) }
          3.times do |step|
            customer = FactoryGirl.create :customer_with_subscriptions
            jwt_validate_token customer
            discount = client.discounts.sample
            customer.discounts << discount
            customer.save!
            post :create,
                 review: {
                   discount_id: discount.id,
                   rate: rates[step],
                   feedback: "feedback#{step}"
                 },
                 customer_id: customer.id,
                 format: :json
            expect(response.status).to eql 201
            response_body = json_response
            expect(response_body[:review]).not_to be_blank
          end
          client_reviews = Client.joins(discounts: :customers_discounts).find client.id
          expect(client_reviews.customers_discounts.length).to eql(3)

          client_rates = client_reviews.customers_discounts.map(&:rate)
          expect(client_rates.sum.fdiv 3).to eql rates.sum.fdiv(3)
          expect(client_reviews.customers_discounts.map(&:feedback)).to include 'feedback0'
        end

        it 'should not be able to review a discount twice' do
          customer = FactoryGirl.create :customer_with_subscriptions
          rate = rand(1..5)
          jwt_validate_token customer
          discount = client.discounts.sample
          customer.discounts << discount
          customer.save!
          # first review
          post :create,
               review: { discount_id: discount.id, rate: rate, feedback: 'feedback' },
               customer_id: customer.id,
               format: :json
          expect(response.status).to eql 201
          customer = Customer.includes(:customers_discounts).find customer.id
          expect(customer.customers_discounts.map(&:discount_id)).to include discount.id
          expect(customer.discounts.map(&:client_id)).to include client.id

          # second review
          post :create,
               review: { discount_id: discount.id, rate: rate, feedback: 'feedback' },
               customer_id: customer.id,
               format: :json
          expect(response.status).to eql 405
        end
      end

      describe 'GET #show' do
        let(:customer) { FactoryGirl.create :customer }

        it 'Authorized customer/client should get a review by id' do
          jwt_validate_token customer
          discount = client.discounts.sample
          customer.discounts << discount
          customer.save!
          post :create,
               review: {
                 discount_id: discount.id,
                 rate: SecureRandom.random_number(5),
                 feedback: 'feedback'
               },
               customer_id: customer.id,
               format: :json
          expect(response.status).to eql 201
          response_body = json_response
          review_id = response_body[:review][:id]

          get :show, id: review_id, format: :json
          expect(response.status).to eql 200
          response_body = json_response
          expect(response_body[:review][:customer_id]).to eql customer.id
          expect(response_body[:review][:discount_id]).to eql discount.id
        end

        it 'should respond with status bad_request if review does not exist' do
          jwt_validate_token customer
          get :show, id: 'fake id', format: :json
          expect(response.status).to eql 400
        end
      end
    end
  end
end
