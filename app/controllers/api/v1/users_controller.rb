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
        req_params = update_params
        current_user = User.new req_params
        if current_user.save
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors }, status: :bad_request
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
    end
  end
end
