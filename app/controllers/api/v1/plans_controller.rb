module API
  module V1
    class PlansController < API::BaseController

      # GET /v1/plans
      def index
        render json: { plans: Plan.all.cache }, status: :ok
      end
    end
  end
end
