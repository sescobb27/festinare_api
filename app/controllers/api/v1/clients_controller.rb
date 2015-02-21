module API
  module V1
    class ClientsController < API::BaseController

      before_action :is_authenticated?, only: [:me]

      # POST /v1/clients/login
      def login
        req_params = safe_params
        client = Client.only(:_id, :username, :email, :encrypted_password).where({
          username: req_params[:username]
        }).first
        if !client.nil? && client.valid_password?(req_params[:password])
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :unauthorized
        end
      end

      # POST /v1/clients/me
      def me
        render json: { client: @current_user_credentials }, status: :ok
      end

      # GET /v1/clients
      def index
      end

      #  POST /v1/clients
      def create
        client = Client.new(safe_params)
        if client.save
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render json: { errors: client.errors }, status: :bad_request
        end
      end

      # GET /v1/clients/:id
      def show
      end

      # PATCH /v1/clients/:id
      # PUT   /v1/clients/:id
      def update
      end

      # DELETE /v1/clients/:id
      def destroy
      end

      private
        def safe_params
          params.require(:client).permit(:username, :email, :name, :password)
        end
    end
  end
end
