module API
  module V1
    class ClientsController < API::BaseController

      before_action :is_authenticated?, only: [:me, :discounts, :update, :purshase_plan]

      # POST /v1/clients/login
      def login
        req_params = safe_params
        client = Client.only(:_id, :username, :email, :encrypted_password).where({
          username: req_params[:username]
        }).first
        if !client.nil? && client.valid_password?(req_params[:password])
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :bad_request
        end
      end

      # GET /v1/clients/:client_id/me
      def me
        render json: { client: @current_user_credentials }, status: :ok
      end

      # GET /v1/clients
      def index
        render nothing: true
      end

      #  POST /v1/clients
      def create
        client = Client.new(safe_params)
        if client.save
          token = authenticate_user client
          render json: { token: token }, status: :ok
        else
          render json: { errors: client.errors.full_messages }, status: :bad_request
        end
      end

      # PATCH /v1/clients/:id
      # PUT   /v1/clients/:id
      def update
        safe_params = safe_update_params
        current_user = Client.find @current_user_credentials[:_id]
        current_user.update_attributes safe_params
        if current_user.errors.empty?
          render nothing: true, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :bad_request
        end
      end

      # POST /v1/clients/purshase/:plan_id
      def purshase_plan
        current_user = Client.find @current_user_credentials[:_id]
        plan = Plan.find params[:plan_id]
        purchased_plan = ClientPlan.new plan.clone.attributes
        purchased_plan._type = 'ClientPlan'
        # the purchased plan is going to expire depending on the plan specifications
        # so for example:
        # DateTime.now => Thu, 12 Mar 2015 21:17:33 -0500
        # plan => {
        #             :currency => "COP",
        #           :deleted_at => nil,
        #          :description => "15% de ahorro",
        #         :expired_rate => 1,
        #         :expired_time => "month",
        #                 :name => "Hurry Up!",
        #     :num_of_discounts => 15,
        #                :price => 127500,
        #               :status => true
        # }
        # the purchased_plan.expired_date = Thu, 12 Apr 2015 21:17:33 -0500
        # 1 month after today
        purchased_plan.expired_date = DateTime.now + plan.expired_rate.send(plan.expired_time)
        current_user.client_plans.push purchased_plan
        render nothing: true, status: :ok
      end

      # DELETE /v1/clients/:id
      def destroy
        render nothing: true
      end

      private
        def safe_params
          params.require(:client).permit(:username, :email, :name, :password, addresses: [])
        end

        def safe_update_params
          params.require(:client).permit(:name, :password, :image_url, addresses: [])
        end
    end
  end
end
