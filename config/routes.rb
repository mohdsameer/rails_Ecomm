Rails.application.routes.draw do
  # Defines the root path route ("/")
  get 'dashboard/producer_panel_dasboard'
  get 'dashboard/inventories'
  get 'dashboard/inventories_second'
  get 'dashboard/manual_order'
  get 'dashboard/choose_shiping'

  resources :dashboard, only: [:show]
  
  
  resources :products, only: [:index, :new, :create,:edit, :update] do
    delete 'remove_variant', on: :member
    get 'edit_producer', on: :member
    patch 'update_producer', on: :member
  end
  
  resources :orders do
    member do
      get :download
      get :confirm
      get :reject
      get :send_message
      post :message_create
      get :cancel_request
      post :update_cancel_status
      get :select_variant
      get :assignee
      post :assignee_create
      get :on_hold_popup
      get :in_production_popup
      get :delete_confirmation
      get :cancel_order
    end
    collection do
      get :add_new_product
      get :select_variant
      get :all_producer
      get :cancel_order_index
    end
  end

  resources :variants do
    get 'inventory_history', on: :collection
    get 'edit_inventory', on: :member
    patch 'update_inventory', on: :member
    get :inventory, on: :collection
    get :producer_inventory, on: :member
  end

  # Sessions routes
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root "dashboard#index"

  get '/etsy/authorize', to: 'etsy#authorize'
  get '/etsy/callback', to: 'etsy#callback'

  resources :payments
end
