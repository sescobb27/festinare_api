require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe DiscountsController, :type => :controller  do

      before do
        request.host = 'api.example.com'
        client_id = rand(100)
        expect({:post => "http://#{request.host}/v1/clients/#{client_id}/discounts"}).to(
          route_to( controller: 'api/v1/discounts',
                    action: 'create',
                    subdomain: 'api',
                    format: :json,
                    client_id: "#{client_id}"
                  )
        )
      end

      let!(:clients) {
        (1..10).map { FactoryGirl.create :client_with_discounts }
      }

      let!(:users) {
        (1..10).map { FactoryGirl.create :user_with_subscriptions }
      }

      let!(:redis) { Cache::RedisCache.instance }

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
          post :create, { client_id: client._id, discount: discount.to_hash }, subdomain: 'api'
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

          len = redis.llen('discounts')
          expect(len).to be > 0
          obj = redis.lrange('discounts', len - 1, len - 1)[0]
          cache_discount = JSON.parse(obj)
          expect(cache_discount['title']).to eql client_discount.title
          expect(cache_discount['_id']['$oid']).to eql client_discount._id.to_s
        end

        it 'should not be able to create a discount' do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
          discount[:duration] = [0, 15, 25, 35, 65, 95, 125].sample
          post :create, { client_id: client._id, discount: discount.to_hash }, subdomain: 'api'
          expect(response.status).to eql 400
          response_body = JSON.parse response.body, symbolize_names: true
          expect(response_body[:errors].length).to be > 0
        end
      end

      describe 'Get all available discounts' do

        it 'user should get all available discounts base on his/her subscriptions' do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
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

      describe 'User Likes a discount' do
        it 'should get a secret key to redeem a discount' do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
          users.map do |user|
            allow(JWT::AuthToken).to(
              receive(:validate_token).and_return({
                _id: user._id,
                username: user.username,
                email: user.email
              })
            )
            clients.each do |client|
              discount = client_discount = Client.find(client._id).discounts.sample
              post :like, { id: user._id, client_id:  client._id, discount_id: discount._id }, subdomain: 'api'
              expect(response.status).to eql 200
              u = User.find(user._id)
              expect(u.discounts).to include discount
            end
          end
        end
      end

      describe 'Client Get all his/her discounts' do
        it 'should return all client discounts' do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
          clients.each do |client|
            allow(JWT::AuthToken).to(
              receive(:validate_token).and_return({
                _id: client._id,
                username: client.username,
                email: client.email
              })
            )
            get :client_discounts, { client_id: client._id }, subdomain: 'api'
            expect(response.status).to eql 200
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:discounts].length).to be == 5
          end
        end
      end
    end
  end
end
