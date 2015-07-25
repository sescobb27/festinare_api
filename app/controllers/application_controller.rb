class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def index
    # render file: "#{Rails.root}/public/index.html", layout: false
    # Rails.application
    # .assets.find_asset('./app/assets/javascripts/app/index.html')
    if Rails.env.development?
      render file: "#{Rails.root}/app/assets/javascripts/app/index.html", layout: false
    else
      render file: "#{Rails.root}/public/index.html", layout: false
    end
  end
end
