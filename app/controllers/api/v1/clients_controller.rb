module API
  module V1
    class ClientsController < API::BaseController
      before_action :authenticated?, only: [:me, :discounts, :update, :logout, :update_password]

      # POST /v1/clients/login
      def login
        safe_params = safe_auth_params

        begin
          client = Client.find_by(username: safe_params[:username])
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :bad_request
        end

        if !client.nil? && client.valid_password?(safe_params[:password])
          token = authenticate_user client
          client.push token: token
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :bad_request
        end
      end

      def logout
        token = auth_token
        begin
          Client.find(@current_user_credentials[:_id]).pull token: token
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        render nothing: true, status: :ok
      end

      # GET /v1/clients/me
      def me
        client = Client.find_by('$and' => [
          { _id: @current_user_credentials[:_id] },
          { token: { '$elemMatch' => { '$eq' => auth_token } } }
        ])
        # client = Client.find(@current_user_credentials[:_id])
        return render json: client, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        return render nothing: true, status: :unauthorized
      end

      # GET /v1/clients
      def index
        render nothing: true
      end

      #  POST /v1/clients
      def create
        safe_params = safe_auth_params
        client = Client.new(safe_params)
        client.token = []
        token = authenticate_user client
        client.token.push token
        if client.save
          render json: { token: token }, status: :ok
        else
          render json: {
            errors: client.errors.full_messages
          }, status: :bad_request
        end
      end

      # PATCH /v1/clients/:id
      # PUT   /v1/clients/:id
      def update
        safe_params = safe_update_params

        begin
          client = Client.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        if safe_params[:password]
          keys = %w(password current_password password_confirmation)

          include_all = keys.all? do |key|
            safe_params[:password].key? key
          end

          if include_all
            if client.update_password safe_params[:password]
              safe_params.delete :password
            else
              return render json: {
                errors: client.errors.full_messages
              }, status: :forbidden
            end
          end
        end

        if safe_params[:address]
          client.add_to_set addresses: safe_params[:address]
          safe_params.delete :address
        end

        # it doesn't update arrays, that's why previous logic
        if client.update safe_params
          render nothing: true, status: :ok
        else
          render json: {
            errors: client.errors.full_messages
          }, status: :bad_request
        end
      end

      # DELETE /v1/clients/:id
      def destroy
        render nothing: true
      end

      private

        def safe_auth_params
          params.require(:client).permit(
            :username,
            :email,
            :name,
            :password,
            addresses: [],
            categories: []
          )
        end

        def safe_update_params
          params.require(:client).permit(
            :name,
            :image_url,
            :address,
            password: [:password, :current_password, :password_confirmation]
          )
        end
    end
  end
end
