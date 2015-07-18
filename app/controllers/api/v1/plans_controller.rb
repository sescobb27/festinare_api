module API
  module V1
    class PlansController < API::BaseController
      before_action :authenticate!, only: :purchase_plan

      # GET /v1/plans
      def index
        render json: Plan.all.cache, status: :ok
      end

      # POST /v1/plans/:plan_id/purchase
      def purchase_plan
        begin
          current_user = Client.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        plan = Plan.find params[:plan_id]
        purchased_plan = plan.to_client_plan
        current_user.client_plans.push purchased_plan
        render nothing: true, status: :ok
      end
    end
  end
end
