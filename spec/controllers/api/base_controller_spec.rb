require 'rails_helper'
require 'auth_token'

module API
  RSpec.describe BaseController, type: :controller  do
    describe '#authenticate_user' do
    end

    describe '#authenticated?' do
      context 'when no authorization heaader' do
      end

      context 'when authorization header' do
        context 'when no JWT token' do
        end

        context 'when invalid JWT token' do
        end

        context 'when invalid params' do
        end

        context 'when valid JWT' do
        end
      end
    end

    describe '#auth_token' do
      it 'should return the JWT token from authorization header' do
        controller.request.headers['Authorization'] = 'Bearer very-large-jwt-token'
        expect(controller.send :auth_token).to eql 'very-large-jwt-token'
      end
    end

    describe '#valid_params?' do
      let(:id) { BSON::ObjectId.new }
      let(:user_id) { BSON::ObjectId.new }
      let(:client_id) { BSON::ObjectId.new }

      before(:each) do
        controller.request.path_parameters = {
          id: id.to_s,
          user_id: user_id.to_s,
          client_id: client_id.to_s
        }
      end

      context 'when valid params' do
        it 'should be valid params' do
          # valid params match the credentials _id included in the JWT
          expect(controller.send :valid_params?, _id: id).to be_truthy
          expect(controller.send :valid_params?, _id: user_id).to be_truthy
          expect(controller.send :valid_params?, _id: client_id).to be_truthy
          # or should not contain ANY path params e.g (me, logout ...)
          controller.request.path_parameters = {}
          expect(controller.send :valid_params?, _id: id).to be_truthy
          expect(controller.send :valid_params?, _id: user_id).to be_truthy
          expect(controller.send :valid_params?, _id: client_id).to be_truthy
        end
      end

      context 'when invalid params' do
        it 'should be invalid params' do
          expect(controller.send :valid_params?, _id: nil).to be_falsey
          expect(controller.send :valid_params?, _id: '').to be_falsey
          expect(controller.send :valid_params?, _id: BSON::ObjectId.new).to be_falsey
        end
      end
    end
  end
end
