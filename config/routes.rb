Rails.application.routes.draw do
  get 'home/index'
  devise_for :users
  get 'sign_out_user', to: 'home#sign_out_user', as: :custom_sign_out
  root to: 'home#index'

  resources :users, only: [:new, :create, :show] do
    resources :bookings do
      member do
        patch :cancel
      end
    end
  end

  resources :rooms, only: [:index]
  resources :bookings, only: [:show]
end
