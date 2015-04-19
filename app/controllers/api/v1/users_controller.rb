module API
  module V1
    class UsersController < API::BaseController
      before_action :is_authenticated?, only: [:me, :update, :mobile]

      def me
        begin
          user = User.find(@current_user_credentials[:_id])
          render json: user, status: :ok
        rescue Mongoid::Errors::DocumentNotFound
          render nothing: true, status: :unauthorized
        end
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
          user_categories = user.categories.map(&:name)
          secure_params[:categories].map do |category|
            # category would have field for adding or removing an element
            should_add = category.delete :status
            if should_add
              unless user_categories.include? category[:name]
                user.categories.push Category.new(category)
              end
            else
              user.pull(categories: { name: category[:name] })
            end
          end
        end
        if secure_params[:name] &&
           !secure_params[:name].empty? &&
           secure_params[:lastname] &&
           !secure_params[:lastname].empty?
          user.update_attributes(
            name: secure_params[:name],
            lastname: secure_params[:lastname]
          )
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
        if user.create_mobile secure_params[:mobile]
          render nothing: true, status: :ok
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :bad_request
        end
      end

      def destroy
      end

      private

        def post_params
          params.require(:user).permit(
            :username,
            :email,
            :lastname,
            :name,
            :password,
            :rate
          )
        end

        def update_params
          params.require(:user).permit(
            :lastname,
            :name, categories: [
              :status,
              :name,
              :description
            ]
          )
        end

        def mobile_params
          params.require(:user).permit(mobile: [:token, :platform])
        end
    end
  end
end
