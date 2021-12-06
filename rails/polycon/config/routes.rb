Rails.application.routes.draw do
  resources :patients
  root "professionals#index"

  resources :professionals
  resources :appointments
end