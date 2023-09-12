Rails.application.routes.draw do
  # Defines the root path route ("/")
  get 'dashboard/index'
  resources :products, only: [:new, :create]
 # Sessions routes
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root "dashboard#index"
end
