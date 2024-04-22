Rails.application.routes.draw do
  resources :orders
  resources :users
  resources :sessions, only: [:create, :destroy]


  post '/signup', to: 'users#create'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/me', to: 'users#show'  
  post 'stkpush', to: 'mpesas#stkpush'
  post 'callback', to: 'mpesa#callback'
  post 'stkquery', to: 'mpesas#stkquery'
end
