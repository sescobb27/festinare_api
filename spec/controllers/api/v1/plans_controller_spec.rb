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

        @request.headers['Accept'] = 'application/json'
        @request.headers['Authorization'] = 'Bearer mysecretkey'
        @request.headers['Content-Type'] = 'application/json'
        mock_token
      end

      describe 'POST #purchase_plan' do
        let(:plan) { Plan.all.to_a.sample }

        let(:client) do
          FactoryGirl.create :client
        end

        it 'should have a plan' do
          jwt_validate_token client
          post :purchase_plan,
               plan_id: plan.id,
               format: :json
          expect(response.status).to eql 200
          client_plans = Client.joins(:clients_plans).find(client.id).clients_plans
          expect(client_plans.length).to eql 1
          expect(client_plans[0].expired_date).to be > Time.zone.now
        end
      end
    end
  end
end
