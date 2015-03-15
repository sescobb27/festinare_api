module API
  module V1
    class ClientsController < API::BaseController

      before_action :is_authenticated?, only: [:me, :discounts, :update, :purshase_plan]

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
          render nothing: true, status: :bad_request
        end
      end

      # GET /v1/clients/:client_id/me
      def me
        begin
          client = Client.find(@current_user_credentials[:_id])
          render json: { client: client }, status: :ok
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
        current_user = Client.find @current_user_credentials[:_id]
        current_user.update_attributes safe_params
        if current_user.errors.empty?
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :bad_request
        end
      end

      # POST /v1/clients/purshase/:plan_id
      def purshase_plan
        current_user = Client.find @current_user_credentials[:_id]
        plan = Plan.find params[:plan_id]
        purchased_plan = plan.to_client_plan
        current_user.client_plans.push purchased_plan
        render nothing: true, status: :ok
      end

      # DELETE /v1/clients/:id
      def destroy
        render nothing: true
      end

      private
        def safe_params
          params.require(:client).permit(:username, :email, :name, :password, addresses: [])
        end

        def safe_update_params
          params.require(:client).permit(:name, :password, :image_url, addresses: [])
        end
    end
  end
end
