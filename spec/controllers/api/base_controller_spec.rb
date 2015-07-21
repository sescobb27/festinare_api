require 'rails_helper'
require 'auth_token'

module API
  RSpec.describe BaseController, type: :controller  do
    describe '#authenticate!' do
      context 'when no authorization heaader' do
        it 'should return 401 unauthorized' do
          expect(controller).to receive(:render).with nothing: true, status: :unauthorized
          controller.authenticate!
        end
      end

      context 'when authorization header' do
        context 'when no JWT token' do
          it 'should return 401 unauthorized' do
            controller.request.headers['Authorization'] = 'Bearer  '
            expect(controller).to receive(:render).with nothing: true, status: :unauthorized
            controller.authenticate!
          end
        end

        context 'when invalid JWT token' do
          it 'should return 401 unauthorized' do
            controller.request.headers['Authorization'] = 'Bearer  invalid_token'
            expect(controller).to receive(:render).with nothing: true, status: :unauthorized
            controller.authenticate!
          end
        end

        context 'when invalid params' do
          it 'should return 401 unauthorized' do
            controller.request.path_parameters = { id: BSON::ObjectId.new.to_s }
            user = FactoryGirl.create :user
            jwt_validate_token user
            expect(controller).to receive(:render).with nothing: true, status: :unauthorized
            controller.authenticate!
          end
        end

        context 'when valid JWT' do
          it 'should set current user credentials' do
            controller.request.headers['Authorization'] = 'Bearer very-large-jwt-token'
            user = FactoryGirl.create :user
            controller.request.path_parameters = { id: user._id.to_s }
            jwt_validate_token user
            controller.authenticate!
            expect(assigns(:current_user_credentials))
              .to eql(_id: user._id.to_s, username: user.username, email: user.email)
          end
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
      let(:customer_id) { BSON::ObjectId.new }
      let(:client_id) { BSON::ObjectId.new }

      before(:each) do
        controller.request.path_parameters = {
          id: id.to_s,
          customer_id: customer_id.to_s,
          client_id: client_id.to_s
        }
      end

      context 'when valid params' do
        it 'should be valid params' do
          # valid params match the credentials _id included in the JWT
          expect(controller.send :valid_params?, _id: id).to be_truthy
          expect(controller.send :valid_params?, _id: customer_id).to be_truthy
          expect(controller.send :valid_params?, _id: client_id).to be_truthy
          # or should not contain ANY path params e.g (me, logout ...)
          controller.request.path_parameters = {}
          expect(controller.send :valid_params?, _id: id).to be_truthy
          expect(controller.send :valid_params?, _id: customer_id).to be_truthy
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
