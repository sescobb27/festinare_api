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

        # token expectations
        # @auth_token = allow(JWT::AuthToken).to(
        #   receive(:make_token).and_return('mysecretkey')
        # )
        # expect(JWT::AuthToken.make_token({}, 3600)).to eq('mysecretkey')
      end

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
    end
  end
end
