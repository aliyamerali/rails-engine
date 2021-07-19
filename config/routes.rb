Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # NON RESTFUL ROUTES
      get '/merchants/find', to: 'merchants#find'

      # RESTFUL ROUTES
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index]
      end
      resources :items, only: [:index, :show, :create, :destroy, :update] do
        get '/merchant', to: 'merchants#show'
      end
    end
  end

end
