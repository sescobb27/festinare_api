module API
  module V1
    class CustomersController < API::BaseController
      # Common logic for User Authentication (create, login, me, logout)
      include UserCategory
      include UserAuth

      def update
        secure_params = safe_update_params
        begin
          customer = Customer.find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end
        if secure_params[:fullname] && !secure_params[:fullname].empty?
          customer.fullname secure_params[:fullname]
        end
        customer.save
        render nothing: true, status: :ok
      end

      def mobile
        secure_params = safe_mobile_params
        begin
          customer = Customer.find(@current_user_credentials[:id])
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end
        customer.mobiles << Mobile.new(secure_params[:mobile])
        if customer.save
          render nothing: true, status: :ok
        else
          render json: {
            errors: customer.errors.full_messages
          }, status: :bad_request
        end
      end

      def likes
        begin
          # Produced QUERY
          # SELECT  "customers".*
          # FROM "customers"
          # INNER JOIN "customers_discounts" ON "customers_discounts"."customer_id" = "customers"."id"
          # INNER JOIN "discounts" ON "discounts"."id" = "customers_discounts"."discount_id"
          # AND "discounts"."status" = 't'
          # INNER JOIN "clients" ON "clients"."id" = "discounts"."client_id"
          # WHERE "customers"."id" = $1 LIMIT 1  [["id", 1]]
          current_customer = Customer.joins(discounts: :client).find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        clients = []
        clients = current_customer.discounts.map(&:client) unless current_customer.customers_discounts.empty?
        render json: clients, status: :ok, each_serializer: LikesSerializer, root: 'clients'
      end

      def safe_auth_params
        params.require(:customer).permit safe_user_auth_params + [:fullname]
      end

      def safe_update_params
        params.require(:customer).permit(
          :fullname,
          categories: [],
          password: [:password, :current_password, :password_confirmation]
        )
      end

      def safe_mobile_params
        params.require(:customer).permit(mobile: [:token, :platform])
      end
    end
  end
end
