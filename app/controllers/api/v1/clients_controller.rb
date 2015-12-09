module API
  module V1
    class ClientsController < API::BaseController
      # Common logic for User Authentication (create, login, me, logout)
      include UserCategory
      include UserAuth

      skip_before_action :authenticate!, only: [:index]

      # GET /api/v1/clients
      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0
        clients = Client.select(
          :id,
          :name,
          :categories,
          :image_url,
          :addresses
        ).limit(limit).offset(offset)
        render json: clients, status: :ok, each_serializer: SecureClientSerializer, root: :clients
      end

      def password_update
        safe_params = safe_update_params

        begin
          client = Client.find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        if client.update_with_password safe_params[:password]
          render nothing: true, status: :ok
        else
          return render json: {
            errors: client.errors.full_messages
          }, status: :forbidden
        end
      end

      # PATCH /api/v1/clients/:id
      # PUT /api/v1/clients/:id
      def update
        safe_params = safe_update_params

        begin
          client = Client.find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        if safe_params[:address]
          client.addresses << safe_params[:address]
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

      # DELETE /api/v1/clients/:id
      def destroy
        render nothing: true, status: :not_implemented
      end

      def safe_auth_params
        params.require(:client).permit(
          safe_user_auth_params.concat [:name, addresses: [], categories: []]
        )
      end

      def safe_update_params
        params.require(:client).permit(
          :name,
          :image_url,
          :address,
          categories: [],
          password: [:password, :current_password, :password_confirmation]
        )
      end
    end
  end
end
