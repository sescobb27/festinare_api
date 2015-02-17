Rails.application.routes.draw do
  root 'application#index'
  namespace :api,
            path: '/',
            constraints: { subdomain: 'api' },
            defaults: { format: :json } do
    # namespace :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
    namespace :v1 do
      with_options except: [:edit, :new] do |except|
        except.resources :users do
          collection do
            post 'login'
            post 'me'
          end
        end
      end
    end
  end
end
