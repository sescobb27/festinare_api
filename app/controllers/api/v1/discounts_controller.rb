module API
  module V1
    class DiscountsController < API::BaseController
      rescue_from Plan::PlanDiscountsExhausted, with: :plan_discounts_exhausted

      before_action :authenticate!

      # GET /v1/discounts?limit=X&offset=X
      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0
        user = User.find @current_user_credentials[:_id]
        categories = user.categories.empty? ? [] : user.categories.map(&:name)
        # clients = Client.only(:_id, :name, :rate, :discounts, :addresses, :categories, :locations).
        #   in('categories.name' => user.categories.map(&:name)).
        #   batch_size(500).
        #   select do |db_client|
        #     db_client.discounts.length > 0
        #   end
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
          # if the client has an active plan but had spend all discounts
          # it would rise Plan::PlanDiscountsExhausted exception
          current_user.decrement_num_of_discounts_left!
          discount = current_user.discounts.create discount_attr
          if discount.errors.empty?
            render json: discount, status: :ok
          else
            render json: {
              errors: discount.errors.full_messages
            }, status: :bad_request
          end
        else
          render json: {
            errors: [
              'You need a plan to create a discount',
              'You have exhausted your plan discounts, you need to purchase a new plan'
            ]
          }, status: :forbidden
        end
      end

      # GET /v1/clients/:client_id/discounts
      def discounts
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
                        .detect do |discount| # the same as select.first or find, but find trigger mongoid query
                          discount.id.to_s == params[:discount_id]
                        end
        if !like_discount.expired? Time.zone.now
          current_user.discounts.push like_discount
          current_user.add_to_set client_ids: params[:client_id]
          like_discount.generate_qr params[:client_id], current_user._id do |qrcode|
            send_data qrcode,
                      filename: "#{like_discount.title}_qrcode.png",
                      type: :png,
                      disposition: 'attachment',
                      status: :ok
          end
        else
          render json: { errors: ['Discount expired'] }, status: :bad_request
        end
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
            errors: ['You have exhausted your plan discounts, you need to purchase a new plan']
          }, status: :forbidden
        end
    end
  end
end
