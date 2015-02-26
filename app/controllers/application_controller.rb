class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  if Rails.env == ''
    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG
    Moped.logger = Logger.new($stdout)
  end

  def index
    render 'layouts/application'
  end
end
