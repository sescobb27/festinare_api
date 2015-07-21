module API
  module V1
    class CustomersController < API::BaseController
      # Common logic for User Authentication (create, login, me, logout)
      include UserAuth

      def update
        secure_params = safe_update_params
        begin
          customer = Customer.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        if secure_params[:categories]
          secure_params[:categories].map do |category|
            # kind of updelete if exist delete, else add
            should_add = category.delete :status
            if should_add
              user_categories = customer.categories.map(&:name)
              unless user_categories.include? category[:name]
                customer.categories.push Category.new(category)
              end
            else
              customer.pull(categories: { name: category[:name] })
            end
          end
        end
        if secure_params[:fullname] && !secure_params[:fullname].empty?
          customer.set fullname: secure_params[:fullname]
        end
        render nothing: true, status: :ok
      end

      def mobile
        secure_params = safe_mobile_params
        begin
          customer = Customer.find(@current_user_credentials[:_id])
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        if customer.update_attributes mobile: secure_params[:mobile]
          render nothing: true, status: :ok
        else
          render json: {
            errors: customer.errors.full_messages
          }, status: :bad_request
        end
      end

      def likes
        begin
          current_customer = Customer.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        clients = []
        clients = Client.find current_customer.client_ids unless current_customer.client_ids.empty?
        render json: clients, status: :ok, each_serializer: LikesSerializer, root: 'clients'
      end

      def safe_auth_params
        params.require(:customer).permit safe_user_auth_params + [:fullname]
      end

      def safe_update_params
        params.require(:customer).permit(
          :fullname,
          categories: [:name, :description, :status],
          password: [:password, :current_password, :password_confirmation]
        )
      end

      def safe_mobile_params
        params.require(:customer).permit(mobile: [:token, :platform])
      end
    end
  end
end
