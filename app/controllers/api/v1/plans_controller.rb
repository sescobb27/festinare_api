module API
  module V1
    class PlansController < API::BaseController
      before_action :authenticate!, only: :purchase_plan

      # GET /api/v1/plans
      def index
        render json: Plan.all, status: :ok
      end

      # POST /api/v1/plans/:plan_id/purchase
      def purchase_plan
        begin
          current_client = Client.includes(:clients_plans).find @current_user_credentials[:id]
        rescue ActiveRecord::RecordNotFound
          return render nothing: true, status: :unauthorized
        end
        plan = Plan.find params[:plan_id]
        ClientsPlan.create_from_plan current_client, plan
        render nothing: true, status: :ok
      end
    end
  end
end
