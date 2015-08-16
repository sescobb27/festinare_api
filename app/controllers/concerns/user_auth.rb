module UserAuth
  include UserConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate!, except: [:login, :create]
  end

  # POST /api/v1/{resource}/login
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

  # POST /api/v1/{resource}/logout
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

  # GET /api/v1/{resource}/me
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

  # POST /api/v1/{resource}
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
