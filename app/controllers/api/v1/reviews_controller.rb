module API
  module V1
    class ReviewsController < API::BaseController
      before_action :authenticate!, except: :show

      # POST /api/v1/users/:user_id/reviews
      def create
        begin
          current_user = User.includes(:reviews).find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        secure_params = post_params
        # only users who had like a discount can review a client
        client_id = secure_params[:client_id]
        if current_user.client_ids.include? client_id
          if current_user.reviews.where(client_id: client_id).exists?
            return render nothing: true, status: :method_not_allowed
          end
          review = Review.new secure_params.merge user_id: params[:user_id]

          return render json: review, status: :created if review.save
          render json: { errors: review.errors }, status: :bad_request
        else
          return render nothing: true, status: :forbidden
        end
      end

      # GET /api/v1/reviews/:id
      def show
        review = Review.find params[:id]
        render json: review, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        return render nothing: true, status: :bad_request
      end

      # PATCH /api/v1/users/:user_id/reviews/:id
      def update
      end

      # DELETE /api/v1/users/:user_id/reviews/:id
      def destroy
      end

      private
        def post_params
          params.require(:review).permit(:client_id, :rate, :feedback)
        end
    end
  end
end
