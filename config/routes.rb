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
          put 'mobile'
          get 'likes'
        end
        resources :reviews, except: [:index, :new, :edit]
      end
      resources :clients, except: [:new, :edit, :show] do
        collection do
          post 'login'
          post 'logout'
          get 'me'
        end
        get 'discounts', controller: 'discounts', action: :discounts
        post 'discounts', controller: 'discounts', action: :create
        resources :reviews, only: :show
      end
      resources :discounts, only: [:index]
      resources :plans, only: :index do # except: [:new, :destroy, :edit]
        post '/purchase', action: :purchase_plan
      end
    end
  end
end
