Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [:index, :show, :create, :destroy, :update]
    resources :companies, only: [:index, :show, :create, :destroy, :update]
    resources :flights, only: [:index, :show, :create, :destroy, :update]
    resources :bookings, only: [:index, :show, :create, :destroy, :update]

    post '/session', to: 'session#create'
    delete '/session', to: 'session#destroy'
  end
end
