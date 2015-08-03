module UserAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!, except: [:login, :create]
  end

  def resource
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    # 'users'
    self.class.to_s.demodulize.underscore.sub(/_controller$/, '')
  end

  def resource_name
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    #                             .singularize
    # 'user'
    resource.singularize
  end

  def resource_model
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    #                             .classify
    #                             .constantize
    # class User < Object {
    #                        :id => :"bson/object_id",
    #                      :_type => :string,
    #       :confirmation_sent_at => :time,
    #         :confirmation_token => :object,
    #               :confirmed_at => :time,
    #                 :created_at => :time,
    #                 :deleted_at => :time,
    #                      :email => :object,
    #         :encrypted_password => :object,
    #     :reset_password_sent_at => :time,
    #       :reset_password_token => :object,
    #                      :token => :array,
    #                   :username => :object
    # }
    resource.classify.constantize
  end

  def login
    safe_params = safe_auth_params

    begin
      user = resource_model.find_by(username: safe_params[:username])
    rescue ActiveRecord::RecordNotFound
      return render nothing: true, status: :bad_request
    end

    if !user.nil? && user.valid_password?(safe_params[:password])
      token = authenticate_user user
      user.tokens << token
      render json: { token: token }, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def logout
    token = auth_token
    begin
      user = resource_model.find(@current_user_credentials[:id])
      user.tokens.delete token
      user.save
    rescue ActiveRecord::RecordNotFound
      return render nothing: true, status: :unauthorized
    end
    render nothing: true, status: :ok
  end

  def me
    # Customer.where('id = :id AND :token = ANY (tokens)',
    #   id: @current_user_credentials[:id],
    #   token: auth_token
    # )
    user = resource_model
           .where(':token = ANY (tokens)', token: auth_token)
           .find @current_user_credentials[:id]
    return render json: user, status: :ok
  rescue ActiveRecord::RecordNotFound
    return render nothing: true, status: :unauthorized
  end

  def create
    user = resource_model.new(safe_auth_params)
    token = authenticate_user user
    user.tokens << token
    if user.save
      token = authenticate_user user
      render json: { token: token }, status: :ok
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :bad_request
    end
  end

  def safe_user_auth_params
    %i(username email password)
  end
end
