module API
  class BaseController < ApplicationController
    require 'auth_token'
    respond_to :json

    before_action :is_authenticated?, only: [:update]

    def authenticate_user user
      # if remember_me the token expiration time is set to a year else 24 hours
      expiration_time = params[:remember_me] ? 31104000 : 86400
      JWT::AuthToken.make_token({
        user_id: user.id,
        username: user.username
      }, expiration_time)
    end

    def is_authenticated?
      unless request.authorization()
        render nothing: true, status: :unauthorized
        return
      end
      token = request.authorization()[7..-1]
      credentials = JWT::AuthToken.validate_token(token)
      if credentials
        @current_user = User.
                          only(:id, :username, :email, :name, :lastname, :rate).
                          find(credentials['user_id'])
      else
        render nothing: true, status: :unauthorized
        return
      end
    end

  end
end
