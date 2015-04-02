module API
  module V1
    class ClientsController < API::BaseController

      before_action :is_authenticated?, only: [:me, :discounts, :update]

      # POST /v1/clients/login
      def login
        safe_params = safe_auth_params

        begin
          client = Client.only(:_id, :username, :email, :encrypted_password).find_by(username: safe_params[:username])
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :bad_request
        end

        if !client.nil? && client.valid_password?(safe_params[:password])
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :bad_request
        end
      end

      # GET /v1/clients/:client_id/me
      def me
        begin
          client = Client.find(@current_user_credentials[:_id])
          render json: client, status: :ok
        rescue Mongoid::Errors::DocumentNotFound
          render nothing: true, status: :unauthorized
        end
      end

      # GET /v1/clients
      def index
        render nothing: true
      end

      #  POST /v1/clients
      def create
        safe_params = safe_auth_params
        client = Client.new(safe_params)
        if client.save
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render json: { errors: client.errors.full_messages }, status: :bad_request
        end
      end

      # PATCH /v1/clients/:id
      # PUT   /v1/clients/:id
      def update
        safe_params = safe_update_params

        begin
          current_user = Client.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        if safe_params[:current_password] && safe_params[:password_confirmation] && safe_params[:password]
          if current_user.valid_password? safe_params[:current_password]
            if safe_params[:password] != safe_params[:password_confirmation]
              safe_params.delete :current_password
              safe_params.delete :password
              safe_params.delete :password_confirmation
            else
              safe_params.delete :current_password
              safe_params.delete :password_confirmation
            end
          end
        end

        if current_user.update safe_params
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :bad_request
        end
      end

      # DELETE /v1/clients/:id
      def destroy
        render nothing: true
      end

      private
        def safe_auth_params
          params.require(:client).permit(:username, :email, :name, :password, addresses: [], categories: [])
        end

        def safe_update_params
          params.require(:client).permit(:name, :password, :current_password, :password_confirmation, :image_url, addresses: [])
        end
    end
  end
end
