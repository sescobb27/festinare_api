require 'api_constraint'

Rails.application.routes.draw do
  devise_for :clients
  devise_for :customers
  root 'application#index'
  namespace :api,
            defaults: { format: :json } do
    namespace :v1, constraints: ApiConstraint::ApiVersionConstraint.new(version: 1, default: true) do
      devise_for :customers, skip: [:sessions, :registrations]
      devise_for :clients, skip: [:sessions, :registrations]
      resources :customers, except: [:new, :edit, :index] do
        collection do
          post 'login'
          post 'logout'
          get 'me'
        end
        member do
          post '/like/discount/:discount_id', controller: 'discounts', action: :like
          put 'mobile'
          get 'likes'
          put '/categories', action: :add_category
          delete '/categories', action: :delete_category
        end
        resources :reviews, except: [:index, :new, :edit, :show]
      end
      resources :clients, except: [:new, :edit, :show] do
        collection do
          post 'login'
          post 'logout'
          get 'me'
        end
        member do
          put '/categories', action: :add_category
          delete '/categories', action: :delete_category
        end
        get 'discounts', controller: 'discounts', action: :discounts
        post 'discounts', controller: 'discounts', action: :create
      end
      resources :reviews, only: :show
      resources :discounts, only: [:index]
      resources :plans, only: :index do # except: [:new, :destroy, :edit]
        post '/purchase', action: :purchase_plan
      end
    end
  end
end
