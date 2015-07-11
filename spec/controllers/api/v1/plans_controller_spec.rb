require 'rails_helper'
require 'auth_token'

module API
  module V1
    RSpec.describe PlansController, type: :controller  do
      before do
        request.host = 'example.com'
        expect(post: "http://#{request.host}/api/v1/clients").to(
          route_to(
            controller: 'api/v1/clients',
            action: 'create',
            format: :json
          )
        )

        # token expectations
        @auth_token = allow(JWT::AuthToken).to(
          receive(:make_token).and_return('mysecretkey')
        )
        expect(JWT::AuthToken.make_token({}, 3600)).to eq('mysecretkey')
      end

      describe 'Client Purchase a Plan' do
        before do
          @request.headers['Accept'] = 'application/json'
          @request.headers['Authorization'] = 'Bearer mysecretkey'
          @request.headers['Content-Type'] = 'application/json'
        end

        let(:plan) { Plan.all.to_a.sample }

        let(:client) do
          FactoryGirl.create :client
        end

        it 'should have a plan' do
          jwt_validate_token client
          post :purchase_plan,
               plan_id: plan._id.to_s,
               format: :json
          expect(response.status).to eql 200
          client_plans = Client.find(client._id).client_plans
          expect(client_plans.length).to eql 1
          expect(client_plans[0].expired_date).to be > Time.zone.now
        end
      end
    end
  end
end
