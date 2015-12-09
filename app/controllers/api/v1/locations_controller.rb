module API
  module V1
    class LocationsController < API::BaseController
      before_action :authenticate!

      def create
        secure_params = safe_params
        begin
          customer = Customer.find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end

        location = Location.new secure_params.merge customer_id: customer.id
        if location.save
          render json: location, status: :created
        else
          render json: { errors: customer.errors.full_messages }, status: :bad_request
        end
      end

      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0
        locations = Location.joins(:customer)
                    .limit(limit)
                    .offset(offset)
        render json: locations, status: :ok
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :unauthorized
      end

      def destroy
      end

      private

        def safe_params
          params.require(:location).permit(:latitude, :longitude, :address)
        end
    end
  end
end
