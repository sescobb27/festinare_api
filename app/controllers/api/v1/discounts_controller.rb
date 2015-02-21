module API
  module V1
    class DiscountsController < API::BaseController

      before_action :is_authenticated?, only: [:create]
      # GET /v1/clients/discounts
      # GET /v1/discounts
      def index
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
