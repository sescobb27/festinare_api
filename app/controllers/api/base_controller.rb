module API
  class BaseController < ApplicationController
    require 'auth_token'
    respond_to :json

    before_action :is_authenticated?, only: [:update]

    def authenticate_user(user)
      # if remember_me the token expiration time is set to a year else 24 hours
      expiration_time = params[:remember_me] ? 31_104_000 : 86_400
      JWT::AuthToken.make_token({
                                  _id: user.id.to_s,
                                  username: user.username,
                                  email: user.email
                                }, expiration_time)
    end

    def is_authenticated?
      unless request.authorization
        render nothing: true, status: :unauthorized
        return
      end
      token = request.authorization[7..-1]
      credentials = JWT::AuthToken.validate_token(token)
      if credentials
        # TODO
        # BUG: when user still has his credentials but it does not exist in DB
        # We need to validate it's existence
        @current_user_credentials = credentials.clone
        @current_user_credentials[:_id] = @current_user_credentials[:_id].to_s
      else
        return render nothing: true, status: :unauthorized
      end
    end
  end
end
