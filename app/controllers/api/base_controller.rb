module API
  class BaseController < ApplicationController
    require 'auth_token'
    respond_to :json

    before_action :authenticated?, only: [:update]

    # for future references => Users/clients with Time.zone
    # around_filter :user_time_zone, :if => :current_user

    # def user_time_zone(&block)
    #   Time.use_zone(current_user.time_zone, &block)
    # end

    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:pid] = Process.pid
      payload[:params] = request.filtered_parameters
    end

    def authenticate_user(user)
      # expiration time is set to a year
      JWT::AuthToken.make_token({
                                  _id: user.id.to_s,
                                  username: user.username,
                                  email: user.email
                                }, 31_104_000)
    end

    def authenticated?
      unless request.authorization
        render nothing: true, status: :unauthorized
        return
      end
      token = auth_token
      credentials = JWT::AuthToken.validate_token(token)
      if credentials && valid_params?(credentials)
        @current_user_credentials = credentials.clone
        @current_user_credentials[:_id] = @current_user_credentials[:_id].to_s
      else
        return render nothing: true, status: :unauthorized
      end
    end

    protected

      def auth_token
        request.authorization[7..-1]
      end

      def valid_params?(credentials)
        # some routes not need authentication id
        return true if (request.path_parameters.keys & %i(id user_id client_id)).empty?
        request.path_parameters[:id] == credentials[:_id].to_s ||
          request.path_parameters[:user_id] == credentials[:_id].to_s ||
          request.path_parameters[:client_id] == credentials[:_id].to_s
      end
  end
end
