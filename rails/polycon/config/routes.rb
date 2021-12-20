Rails.application.routes.draw do
  root to: "appointments#index"

  devise_for :users
  devise_for :roles
  scope '/admin' do
    resources :users
    resources :roles
  end

  resources :professionals
  delete 'cancel_all_appointments' => "professionals#cancel_all_appointments"
  resources :appointments
  resources :patients
end