Rails.application.routes.draw do
  root "professionals#index"

  resources :professionals
  resources :appointments
end