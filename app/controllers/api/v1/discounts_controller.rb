module API
  module V1
    class DiscountsController < API::BaseController

      before_action :is_authenticated?
      # GET /v1/discounts
      def index
        user = User.only(:_id, :categories).find( @current_user_credentials[:_id] )
        clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
          in('categories.name' => user.categories.map(&:name)).
          batch_size(500).
          select do |db_client|
            db_client.discounts.length > 0
          end

        # render json: clients.map(&:discounts)
        render json: clients, each_serializer: ClientsDiscountSerializer
      end

      # POST /v1/clients/:client_id/discounts
      def create
        discount_attr = safe_discount
        current_user = Client.find( @current_user_credentials[:_id] )
        current_user.discounts.push Discount.new(discount_attr)
        if current_user.save
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors }, status: :bad_request
        end
      end

      # GET /v1/clients/:client_id/discounts
      def client_discounts
        client = Client.unscoped.
                      only(:_id, :discounts).
                      find('54f33dec6b69721d70000000')
        render json: client.discounts, status: :ok
      end

      # POST /v1/clients/:client_id/like/:discount_id
      def like
        like_discount = Client.only(:_id, :discounts).
          find(params[:client_id]).
          discounts.
          select do |discount|
            discount.id.to_s == params[:discount_id]
          end.shift
        current_user = User.find( @current_user_credentials[:_id] )
        current_user.discounts < like_discount
        current_user.save
      end

      private
        def safe_discount
          params.require(:discount).permit(:title, :secret_key, :duration, :discount_rate, hashtags: [])
        end
    end
  end
end
