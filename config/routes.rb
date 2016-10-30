Rails.application.routes.draw do
  # resources :line_items
  resources :line_items do
     member do
       put 'minus'
     end
   end

  resources :carts
  root 'store#index', as: 'store_index'

  resources :products
end
