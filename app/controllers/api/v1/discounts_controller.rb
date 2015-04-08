module API
  module V1
    class DiscountsController < API::BaseController
      rescue_from Plan::PlanDiscountsExhausted, :with => :plan_discounts_exhausted

      before_action :is_authenticated?

      # GET /v1/discounts
      def index
        user = User.only(:_id, :categories).find @current_user_credentials[:_id]
        clients = []
        if user.categories.empty?
          clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
            batch_size(500).
            select do |db_client|
              db_client.discounts.length > 0
            end
        else
          clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
            in('categories.name' => user.categories.map(&:name)).
            batch_size(500).
            select do |db_client|
              db_client.discounts.length > 0
            end
        end

        # render json: clients.map(&:discounts)
        render json: clients, each_serializer: ClientsDiscountSerializer
      end

      # POST /v1/clients/:client_id/discounts
      def create
        discount_attr = safe_discount

        begin
          current_user = Client.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        if current_user.has_plan?
          # if the client has an active plan but had spend all discounts it would rise Plan::PlanDiscountsExhausted exception
          current_user.decrement_num_of_discounts_left!
          discount = current_user.discounts.create discount_attr
          if discount.errors.empty?
            DiscountCache::cache discount, current_user.categories
            render nothing: true, status: :ok
          else
            render json: { errors: discount.errors.full_messages }, status: :bad_request
          end
        else
          render json: { errors: ['You need a plan to create a discount'] }, status: :forbidden
        end
      end

      # GET /v1/clients/:client_id/discounts
      def client_discounts
        begin
          client = Client.only(:_id, :discounts).find(@current_user_credentials[:_id])
          render json: client.discounts.unscoped, status: :ok
        rescue Mongoid::Errors::DocumentNotFound
          render nothing: true, status: :unauthorized
        end
      end

      # POST /v1/users/:id/like/:client_id/discount/:discount_id
      def like
        like_discount = Client.only(:_id, :discounts).
          find(params[:client_id]).
          discounts.
          select do |discount|
            discount.id.to_s == params[:discount_id]
          end.shift
        current_user = User.find( @current_user_credentials[:_id] )
        current_user.discounts << like_discount
        current_user.save
        render nothing: true, status: :ok
      end

      private
        def safe_discount
          params.require(:discount).permit(:title, :secret_key, :duration, :discount_rate, hashtags: [])
        end

        def plan_discounts_exhausted
          render json: { errors: ['You have exhausted your plan discounts, you need to purchase a new plan'] }, status: :forbidden
        end
    end
  end
end
