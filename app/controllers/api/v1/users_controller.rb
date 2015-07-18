module API
  module V1
    class UsersController < API::BaseController
      before_action :authenticate!, only: [:me, :update, :mobile, :review, :likes]

      def me
        user = User.find(@current_user_credentials[:_id])
        render json: user, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        render nothing: true, status: :unauthorized
      end

      def login
        req_params = post_params
        begin
          user = User.only(:_id, :username, :email, :encrypted_password)
                 .find_by username: req_params[:username]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        if !user.nil? && user.valid_password?(req_params[:password])
          token = authenticate_user user
          render json: { token: token }, status: :ok
        else
          render nothing: true, status: :unauthorized
        end
      end

      def create
        user = User.new(post_params)
        if user.save
          token = authenticate_user user
          render json: { token: token }, status: :ok
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :bad_request
        end
      end

      # PUT /v1/users/:id
      def update
        secure_params = update_params
        begin
          user = User.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        if secure_params[:categories]
          secure_params[:categories].map do |category|
            # kind of updelete if exist delete, else add
            should_add = category.delete :status
            if should_add
              user_categories = user.categories.map(&:name)
              unless user_categories.include? category[:name]
                user.categories.push Category.new(category)
              end
            else
              user.pull(categories: { name: category[:name] })
            end
          end
        end
        if secure_params[:fullname] && !secure_params[:fullname].empty?
          user.set fullname: secure_params[:fullname]
        end
        render nothing: true, status: :ok
      end

      # PUT /v1/users/:id/mobile
      def mobile
        secure_params = mobile_params
        begin
          user = User.find(@current_user_credentials[:_id])
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end
        if user.update_attributes mobile: secure_params[:mobile]
          render nothing: true, status: :ok
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :bad_request
        end
      end

      # GET /api/v1/users/:id/likes
      def likes
        begin
          current_user = User.find @current_user_credentials[:_id]
        rescue Mongoid::Errors::DocumentNotFound
          return render nothing: true, status: :unauthorized
        end

        clients = []
        clients = Client.find current_user.client_ids unless current_user.client_ids.empty?
        render json: clients, status: :ok, each_serializer: LikesSerializer, root: 'clients'
      end

      def destroy
      end

      private

        def post_params
          params.require(:user).permit(
            :username,
            :email,
            :fullname,
            :password,
            :rate
          )
        end

        def update_params
          params.require(:user).permit(
            :fullname,
            categories: [
              :name,
              :description,
              :status
            ]
          )
        end

        def mobile_params
          params.require(:user).permit(mobile: [:token, :platform])
        end
    end
  end
end
