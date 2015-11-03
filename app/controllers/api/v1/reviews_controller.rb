module API
  module V1
    class ReviewsController < API::BaseController
      before_action :authenticate!, except: :show

      # POST /api/v1/customers/:customer_id/reviews
      def create
        secure_params = post_params
        begin
          current_customer = Customer
                             .includes(:customers_discounts)
                             .where(customers_discounts: { discount_id: secure_params[:discount_id] })
                             .limit(1)
                             .find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        # only customers who had like a discount can review a discount
        if current_customer.customers_discounts.empty?
          return render nothing: true, status: :forbidden
        end

        review = current_customer.customers_discounts.first
        # customers only can review a discount once
        unless review.rate.blank? || review.rate == 0
          return render nothing: true, status: :method_not_allowed
        end

        review.rate = secure_params[:rate]
        review.feedback = secure_params[:feedback]

        return render json: review, status: :created, serializer: ReviewSerializer if review.save
        render json: { errors: review.errors }, status: :bad_request
      end

      # GET /api/v1/reviews/:id
      def show
        review = CustomersDiscount.find params[:id]
        render json: review, status: :ok, serializer: ReviewSerializer
      rescue ActiveRecord::RecordNotFound
        return render nothing: true, status: :bad_request
      end

      # PATCH /api/v1/customers/:customer_id/reviews/:id
      # PUT /api/v1/customers/:customer_id/reviews/:id
      def update
        render nothing: true, status: :not_implemented
      end

      # DELETE /api/v1/customers/:customer_id/reviews/:id
      def destroy
        render nothing: true, status: :not_implemented
      end

      private
        def post_params
          params.require(:review).permit(:discount_id, :rate, :feedback)
        end
    end
  end
end
