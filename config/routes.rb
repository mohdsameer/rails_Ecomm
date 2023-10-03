Rails.application.routes.draw do

# Defines the root path route ("/")
  get 'dashboard/producer_panel_dasboard'
  get 'dashboard/inventories'
  get 'dashboard/inventories_second'
  get 'dashboard/manual_order'
  
  
  resources :products, only: [:index, :new, :create,:edit, :update] do
     delete 'remove_variant', on: :member
     get 'edit_producer', on: :member
     patch 'update_producer', on: :member
  end
  
  resources :orders
  resources :variants do
     get 'inventory_history', on: :collection
     get 'edit_inventory', on: :member
     patch 'update_inventory', on: :member
  end
# Etsy routes
  get '/import_etsy_products', to: 'etsy_import#import_products' 
# Sessions routes
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root "dashboard#index"
  # root "sessions#new"
end
