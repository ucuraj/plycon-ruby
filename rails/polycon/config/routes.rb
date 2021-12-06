Rails.application.routes.draw do
  root to: "appointments#index"

  devise_for :users
  scope '/admin' do
    resources :users
  end
  resources :roles

  resources :professionals
  resources :appointments
  resources :patients
end