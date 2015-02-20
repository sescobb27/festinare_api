require 'api_version_constraints'

Rails.application.routes.draw do
  root 'application#index'
  namespace :api,
            path: '/',
            constraints: { subdomain: 'api' },
            defaults: { format: :json } do
    # namespace :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
    namespace :v1 do

      resources :users, except: [:new, :edit] do
        collection do
          post 'login'
          post 'me'
        end
        member do
          post 'like'
        end
      end
      resources :clients, except: [:new, :edit] do
        collection do
          post 'login'
          post 'me'
        end
        resources :discouts, only: [:index, :create, :show]
      end
      resources :discouts, only: [:index]
      resources :plans, except: [:new, :destroy, :edit]
    end
  end
end
