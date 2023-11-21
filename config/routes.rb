Rails.application.routes.draw do
  root "dashboard#index"

  get 'dashboard/producer_panel_dasboard'
  get 'dashboard/choose_shiping'
  get 'dashboard/payment_amount_popup'
  get '/states', to: 'addresses#get_states'

  resources :dashboard, only: [:show]

  resources :products, only: [:index, :show, :new, :create,:edit, :update] do
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
      get :assignee_remove_confirmation
      delete :assigne_remove
      get :on_hold_popup
      get :in_production_popup
      get :rejected_popup
      get :fullfilled_popup
      get :delete_confirmation
      get :cancel_order
      get :new_cancel_request
      post :create_cancel_request
      get :update_priority
      get :request_revision
      patch :request_revision_update
      post :create_address
      post :order_update_shipping
      delete :remove_product
      get :set_dimensions
      post :update_dimensions
      get :update_job_price
      patch :assigne_update_price
      get :order_slip
      get :duplicate_order
      get :edit_sender
      post :update_sender
      delete :remove_shipo_lable
      get :download_shippo_label
    end

    collection do
      get :add_new_product
      get :select_variant
      get :all_producer
      get :cancel_order_index
      get :new_order_product
    end
  end

  resources :variants do
    get 'inventory_history', on: :collection
    get 'edit_inventory', on: :member
    get 'edit_aisle_no', on: :member
    patch 'update_inventory', on: :member
    get :inventory, on: :collection
    get :producer_inventory, on: :member
  end

  # Sessions routes
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/etsy/authorize', to: 'etsy#authorize'
  get '/etsy/callback', to: 'etsy#callback'

  resources :payments
end
