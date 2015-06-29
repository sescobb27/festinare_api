require 'api_constraint'

Rails.application.routes.draw do
  root 'application#index'
  namespace :api,
            defaults: { format: :json } do
    namespace :v1, constraints: ApiConstraint::ApiVersionConstraint.new(version: 1, default: true) do
      devise_for :users, skip: [:sessions, :registrations]
      devise_for :clients, skip: [:sessions, :registrations]
      resources :users, except: [:new, :edit, :index] do
        collection do
          post 'login'
          post 'logout'
          get 'me'
        end
        member do
          post '/like/:client_id/discount/:discount_id',
               controller: 'discounts',
               action: :like
          post '/review/:client_id', action: 'review'
          put 'mobile'
        end
      end
      resources :clients, except: [:new, :edit, :show] do
        collection do
          post 'login'
          post 'logout'
          get 'me'
          get 'users/:id', action: 'liked_clients'
        end
        get 'discounts', controller: 'discounts', action: :client_discounts
        post 'discounts', controller: 'discounts', action: :create
      end
      resources :discounts, only: [:index]
      resources :plans, only: :index do # except: [:new, :destroy, :edit]
        post '/purchase', action: :purchase_plan
      end
    end
  end
end
