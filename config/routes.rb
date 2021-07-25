Rails.application.routes.draw do
  namespace :api do
    resources :users
    resources :companies
    resources :flights
    resources :bookings
  end
end
