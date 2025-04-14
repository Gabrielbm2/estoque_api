Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      post '/login', to: 'auth#login'
      post '/register', to: 'auth#register'
      get '/me', to: 'auth#me'

      resources :users do
        member do
          patch :make_admin
        end
      end

      resources :file_images, only: [:create, :show, :destroy]

      resources :products do
        member do
          post 'update_stock', to: 'products#update_stock'
        end
      end

      get '/users/:user_id/products', to: 'products#index'

      post '/forgot_password', to: 'passwords#forgot'
      post '/reset_password', to: 'passwords#reset'
    end
  end
end