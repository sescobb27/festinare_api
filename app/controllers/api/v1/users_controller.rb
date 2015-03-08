module API
  module V1
    class UsersController < API::BaseController

      before_action :is_authenticated?, only: [:me]

      def me
        render json: { user: @current_user_credentials }, status: :ok
      end

      def login
        req_params = safe_params
        user = User.only(:_id, :username, :email, :encrypted_password).where({
          username: req_params[:username]
        }).first
        if !user.nil? && user.valid_password?(req_params[:password])
          token = authenticate_user user
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :unauthorized
        end
      end

      def create
        user = User.new(safe_params)
        if user.save
          token = authenticate_user user
          render json: { token: token }, status: :ok
        else
          render json: { errors: user.errors }, status: :bad_request
        end
      end

      def update
      end

      # POST /v1/users/:id/mobile
      def mobile
        secure_params = mobile_params
        user = User.find( params[:id] )
        user.mobile = Mobile.new secure_params[:mobile]
        if user.save
          render nothing: true, status: :ok
        else
          render json: { errors: user.errors }, status: :bad_request
        end
      end

      def destroy

      end

      private
        def safe_params
          params.require(:user).permit(:username, :email, :lastname, :name, :password, :rate)
        end

        def update_params
          params.require(:user).permit(:lastname, :name, :password)
        end

        def mobile_params
          params.require(:user).permit(mobile: [:token, :platform])
        end
    end
  end
end
