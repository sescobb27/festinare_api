require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe DiscountsController, :type => :controller  do

      before do
        request.host = 'api.example.com'
        client_id = rand(100)
        expect({:post => "http://#{request.host}/v1/discounts"}).to(
          route_to( controller: 'api/v1/discounts',
                    action: 'create',
                    subdomain: 'api',
                    format: :json
                  )
        )
      end

      let!(:clients) {
        (1..10).map { FactoryGirl.create :user_with_discounts }
      }

      let!(:users) {
        (1..10).map { FactoryGirl.create :user_with_subscriptions }
      }

      describe 'Create Discount' do

        let!(:client) {
          client_attr = FactoryGirl.attributes_for :client
          Client.create client_attr
        }

        let!(:discount) { FactoryGirl.attributes_for(:discount) }

        before do
          @auth_token = allow(JWT::AuthToken).to(
            receive(:validate_token).and_return({
              _id: client._id,
              username: client.username,
              email: client.email
            })
          )
        end

        it 'should be able to create a discount' do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
          post :create, { discount: discount.to_hash }, subdomain: 'api'
          expect(response.status).to eql 200

          client_discount = Client.where({
            _id: client._id,
            username: client.username,
            email: client.email
          }).first.discounts.first

          expect(client_discount.discount_rate).to eql discount[:discount_rate]
          expect(client_discount.title).to eql discount[:title]
          expect(client_discount.secret_key).to eql discount[:secret_key]
          expect(client_discount.status).to eql discount[:status]
          expect(client_discount.duration).to eql discount[:duration]
          expect(client_discount.hashtags).to eql discount[:hashtags]
        end
      end

      describe 'Get all available discounts' do

        it 'user should get all available discounts base on his/her subscriptions' do
          users.map do |user|
            allow(JWT::AuthToken).to(
              receive(:validate_token).and_return({
                _id: user._id,
                username: user.username,
                email: user.email
              })
            )
            expect({get: "http://#{request.host}/v1/discounts"}).to(
              route_to(
                controller: 'api/v1/discounts',
                action: 'index',
                subdomain: 'api',
                format: :json
              )
            )
            @request.headers['Authorization'] = 'Bearer mysecretkey'
            get :index, {}, format: :json
            c_ins_user_cred = assigns :current_user_credentials
            expect(response.status).to eql 200
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:discounts].length).to be > 0
            response_body[:discounts].each do |client|
              expect(client[:discounts].length).to be > 0
              expect(client[:addresses].length).to be > 0
              expect(client[:locations].length).to be > 0
              client_categories = client[:categories].map { |c| c[:name] }
              user_subscriptions = user.categories.map { |c| c[:name] }
              expect( client_categories & user_subscriptions ).not_to be_empty
            end
          end
        end
      end
    end
  end
end
