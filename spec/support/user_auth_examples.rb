class Symbol
  # convert symbol to model
  # :customer.to_s.classify.constantize
  # => Customer
  # :client.to_s.classify.constantize
  # => Client
  def to_model
    # self.to_s.classify.constantize
    to_s.classify.constantize
  end
end

# Shared examples for User
# Customer < User
# Client < User
# ClientsController include UserAuth
# CustomersController include UserAuth
# params @model_type = :customer, :client
RSpec.shared_context 'User' do |model_type|
  describe 'POST #create' do
    let(:user) { FactoryGirl.attributes_for(model_type) }

    it 'should return a token' do
      params = {}
      params[model_type] = user

      post :create, params, format: :json

      expect(response.status).to eql 200
      response_body = json_response
      expect(response_body[:token]).to eql 'mysecretkey'
    end

    it 'should return status bad request for short passwords' do
      user['password'] = 'qwerty'
      params = {}
      params[model_type] = user

      post :create, params, format: :json

      expect(response.status).to eql 400
      response_body = json_response
      expect(response_body[:errors].length).to eql 1
    end
  end

  describe 'POST #login' do
    let!(:user) do
      user_attrs = FactoryGirl.attributes_for model_type
      # Client.create! user_attrs
      # Customer.create! user_attrs
      model_type.to_model.create! user_attrs
      user_attrs
    end

    it 'should be successfully logged in' do
      params = {}
      params[model_type] = user

      post :login, params, format: :json

      expect(response.status).to eql 200
      response_body = json_response
      expect(response_body[:token]).to eql 'mysecretkey'
      # Client.find_by username: user[:username]
      # Customer.find_by username: user[:username]
      cli = model_type.to_model.find_by username: user[:username]
      expect(cli.token).to include user[:token][0]
    end

    it 'should return status unauthorized if password not match' do
      user['password'] = 'wrong_password'
      params = {}
      params[model_type] = user

      post :login, params, format: :json

      expect(response.status).to eql 400
      expect(response.body).to eql ''
    end

    it 'should return status unauthorized if username not match' do
      user['username'] = 'wrong_username'
      params = {}
      params[model_type] = user

      post :login, params, format: :json

      expect(response.status).to eql 400
      expect(response.body).to eql ''
    end
  end

  describe 'POST #logout' do
    let(:user) do
      FactoryGirl.create model_type, token: ['mysecretkey']
    end

    it 'should be logged out and token should be removed' do
      jwt_validate_token user

      post :logout, format: :json

      expect(response.status).to eql 200
      # Client.find user._id
      # Customer.find user._id
      user_tmp = model_type.to_model.find user._id
      expect(user_tmp.token).not_to include 'mysecretkey'
    end

    it 'should respond status code unauthorized' do
      jwt_validate_token user

      post :logout, format: :json

      expect(response.status).to eql 200

      params = {}
      params[model_type] = user

      get :me, params, format: :json

      expect(response.status).to eql 401
      # Client.find user._id
      # Customer.find user._id
      user_tmp = model_type.to_model.find user._id
      expect(user_tmp.token).not_to include 'mysecretkey'
    end
  end

  describe 'GET #me' do
    let(:user) do
      FactoryGirl.create model_type, token: ['mysecretkey']
    end

    it 'should return user\'s attributes' do
      jwt_validate_token user
      params = {}
      params[model_type] = user

      get :me, params, format: :json

      expect(response.status).to eql 200
      response_body = json_response
      expect(response_body[model_type][:_id]).to eql user._id.to_s
      expect(response_body[model_type][:email]).to eql user.email
      expect(response_body[model_type][:password]).to be_nil
      expect(response_body[model_type][:username]).to eql user.username
    end

    it 'should respond with status code unauthorized' do
      user.pull token: 'mysecretkey'
      jwt_validate_token user
      params = {}
      params[model_type] = user

      get :me, params, format: :json

      expect(response.status).to eql 401
    end
  end
end
