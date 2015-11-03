module API
  module V1
    class DiscountsController < API::BaseController
      rescue_from ClientsPlan::PlanDiscountsExhausted, with: :plan_discounts_exhausted

      before_action :authenticate!

      # GET /api/v1/discounts?limit=X&offset=X
      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0
        customer = Customer.includes(:discounts).find @current_user_credentials[:id]
        liked_discounts = customer.discounts.pluck(:id)

        # customers can only get discounts who they haven't liked yet
        discounts = Discount.available customer.categories,
                                       limit: limit,
                                       offset: offset,
                                       omit: liked_discounts

        render json: discounts
      end

      # POST /api/v1/clients/:client_id/discounts
      def create
        discount_attr = safe_discount

        begin
          current_client = Client.includes(:discounts, :clients_plans).find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        # if the client has an active plan but had spend all discounts
        # it would rise ClientsPlan::PlanDiscountsExhausted exception
        current_client.decrement_num_of_discounts_left!
        discount = Discount.new discount_attr
        if discount.valid?
          current_client.discounts << discount
          render json: discount, status: :created
        else
          render json: {
            errors: discount.errors.full_messages
          }, status: :bad_request
        end
      end

      # GET /api/v1/clients/:client_id/discounts
      def discounts
        client = Client.includes(discounts: [:customers_discounts]).find(@current_user_credentials[:id])
        render json: client.discounts, status: :ok
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :unauthorized
      end

      # POST /api/v1/customers/:id/like/discount/:discount_id
      def like
        begin
          current_customer = Customer.includes(:discounts).find(@current_user_credentials[:id])
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end
        like_discount = Discount.not_expired.find(params[:discount_id])

        if like_discount.nil? || like_discount.expired?(Time.zone.now)
          return render json: { errors: ['Discount expired'] }, status: :bad_request
        end

        current_customer.discounts << like_discount
        like_discount.generate_qr params[:client_id], current_customer.id do |qrcode|
          send_data qrcode,
                    filename: "#{like_discount.title}_qrcode.png",
                    type: :png,
                    disposition: 'attachment',
                    status: :ok
        end
      end

      # POST /api/v1/clients/:client_id/discounts/:id
      def redeem
        begin
          # SELECT  DISTINCT "clients"."id"
          # FROM "clients"
          # LEFT OUTER JOIN "discounts"
          # ON "discounts"."client_id" = "clients"."id"
          # LEFT OUTER JOIN "customers_discounts"
          # ON "customers_discounts"."discount_id" = "discounts"."id"
          # LEFT OUTER JOIN "customers"
          # ON "customers"."id" = "customers_discounts"."customer_id"
          # WHERE "discounts"."id" = $1
          # AND "customers"."id" = 1
          # AND "clients"."id" = $2
          # LIMIT 1  [["id", 3], ["id", 1]]
          current_client = Client.includes(discounts: :customers)
                           .where(
                             discounts: { id: params[:id] },
                             customers: { id: params[:customer_id] }
                           )
                           .find(@current_user_credentials[:id])
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        discount = current_client.discounts.first
        if current_client.discounts.empty? || discount.id != params[:id].to_i
          return render json: { errors: ['Discount not found'] }, status: :not_found
        end

        begin
          if Discount.redeem discount, params[:discount][:secret_key]
            render json: discount, status: :ok
          else
            render json: { errors: discount.errors.full_messages }, status: :bad_request
          end
        rescue ActiveRecord::RecordNotFound
          return render json: { errors: ['Discount not found'] }, status: :not_found
        rescue Discount::SecretKeyNotMatchError
          return render json: { errors: ['Secret Key Not Match'] }, status: :forbidden
        rescue Discount::AlreadyRedeemedError
          return render json: { errors: ['Already Redeemed Discount'] }, status: :forbidden
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
            errors: [
              "You don't have a plan or You have exhausted all your plan discounts, you need to purchase a new plan"
            ]
          }, status: :forbidden
        end
    end
  end
end
