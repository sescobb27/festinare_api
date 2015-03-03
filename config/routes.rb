require 'api_version_constraints'

Rails.application.routes.draw do
  root 'application#index'
  namespace :api,
            path: '/',
            constraints: { subdomain: 'api' },
            defaults: { format: :json } do
    # namespace :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
    namespace :v1 do

      resources :users, except: [:new, :edit, :index] do
        collection do
          post 'login'
          post 'me'
        end
        member do
          post '/like/:client_id/discount/:discount_id', controller: 'discounts', action: :like
        end
      end
      resources :clients, except: [:new, :edit, :show] do
        collection do
          post 'login'
          get 'me'
        end
        get 'discounts', controller: 'discounts', action: :client_discounts
        post 'discounts', controller: 'discounts', action: :create
      end
      resources :discounts, only: [:index]
      resources :plans, except: [:new, :destroy, :edit]
    end
  end
end
