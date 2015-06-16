module API
  module V1
    class DiscountsController < API::BaseController
      rescue_from Plan::PlanDiscountsExhausted, with: :plan_discounts_exhausted

      before_action :authenticated?

      # GET /v1/discounts?limit=X&offset=X
      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0
        user = User.find @current_user_credentials[:_id]
        categories = user.categories.empty? ? [] : user.categories.map(&:name)
        # rubocop:disable Metrics/LineLength
        # clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
        #   in('categories.name' => user.categories.map(&:name)).
        #   batch_size(500).
        #   select do |db_client|
        #     db_client.discounts.length > 0
        #   end
        # rubocop:enable Metrics/LineLength
        clients = Client.available_discounts categories,
                                             limit: limit, offset: offset

        # users can only get discounts who they haven't liked yet
        unless user.discounts.empty?
          liked_discounts = user.discounts.map do |discount|
            discount._id.to_s
          end
          clients.each do |client|
            likeable_discounts = client.discounts.map do |discount|
              id = discount._id.to_s
              discount unless liked_discounts.include? id
            end.compact

            client.discounts = likeable_discounts
          end
        end

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

        if current_user.plan?
          # rubocop:disable Metrics/LineLength
          # if the client has an active plan but had spend all discounts it would rise Plan::PlanDiscountsExhausted exception
          # rubocop:enable Metrics/LineLength
          current_user.decrement_num_of_discounts_left!
          discount = current_user.discounts.create discount_attr
          if discount.errors.empty?
            DiscountCache.cache discount, current_user.categories
            render json: discount, status: :ok
          else
            render json: {
              errors: discount.errors.full_messages
            }, status: :bad_request
          end
        else
          # rubocop:disable Metrics/LineLength
          render json: {
            errors: [
              'You need a plan to create a discount',
              'You have exhausted your plan discounts, you need to purchase a new plan'
            ]
          }, status: :forbidden
          # rubocop:enable Metrics/LineLength
        end
      end

      # GET /v1/clients/:client_id/discounts
      def client_discounts
        client = Client.only(:_id, :discounts)
                 .find(@current_user_credentials[:_id])
        render json: client.discounts.unscoped, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        render nothing: true, status: :unauthorized
      end

      # POST /v1/users/:id/like/:client_id/discount/:discount_id
      def like
        begin
          current_user = User.find(@current_user_credentials[:_id])
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        like_discount = Client.only(:_id, :discounts)
                        .find(params[:client_id])
                        .discounts
                        .select do |discount|
                          discount.id.to_s == params[:discount_id]
                        end.shift
        current_user.discounts.push like_discount
        current_user.add_to_set client_ids: params[:client_id]
        render json: { secret_key: like_discount.secret_key }, status: :ok
      end

      private

        def safe_discount
          params.require(:discount).permit(
            :title,
            :secret_key,
            :duration,
            :discount_rate,
            hashtags: []
          )
        end

        def plan_discounts_exhausted
          render json: {
            # rubocop:disable Metrics/LineLength
            errors: ['You have exhausted your plan discounts, you need to purchase a new plan']
            # rubocop:enable Metrics/LineLength
          }, status: :forbidden
        end
    end
  end
end
