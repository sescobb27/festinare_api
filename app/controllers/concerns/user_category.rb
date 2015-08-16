module UserCategory
  include UserConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate!
  end

  # PUT /api/v1/{resource}/:id/categories
  def add_category
    secure_params = safe_update_params
    begin
      user = resource_model.find(@current_user_credentials[:id])
    rescue ActiveRecord::RecordNotFound
      return render nothing: true, status: :unauthorized
    end
    categories = secure_params[:categories]
    user_categories = (user.categories + categories).uniq
    user.categories = user_categories
    user.save
    render nothing: true, status: :created
  end

  # DELETE /api/v1/{resource}/:id/categories
  def delete_category
    secure_params = safe_update_params
    begin
      user = resource_model.find(@current_user_credentials[:id])
    rescue ActiveRecord::RecordNotFound
      return render nothing: true, status: :unauthorized
    end
    user.categories -= secure_params[:categories]
    user.save
    render nothing: true, status: :ok
  end
end
