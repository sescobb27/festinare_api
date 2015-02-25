module API
  module V1
    class DiscountsController < API::BaseController

      before_action :is_authenticated?, only: [:create, :index]
      # GET /v1/clients/discounts
      # GET /v1/discounts
      def index
        user = User.only(:_id, :categories).find_by(@current_user_credentials)
        clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
          in('categories.name' => user.categories.map(&:name)).
          batch_size(500).
          select do |db_client|
            db_client.discounts.length > 0
          end

        # render json: clients.map(&:discounts)
        render json: clients, each_serializer: ClientsDiscountSerializer
      end

      # POST /v1/clients/discounts
      def create
        discount_attr = safe_discount
        current_user = Client.where( @current_user_credentials ).first
        current_user.discounts.push Discount.new(discount_attr)
        if current_user.save
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors }, status: :bad_request
        end
      end

      # GET /v1/clients/discounts/:id
      def show
      end

      private
        def safe_discount
          params.require(:discount).permit(:title, :secret_key, :duration, :discount_rate, hashtags: [])
        end
    end
  end
end
