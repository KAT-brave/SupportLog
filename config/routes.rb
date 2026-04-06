Rails.application.routes.draw do
  get "home/index"
  root "home#index"

  resource :registration, only: %i[new create]
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]

  namespace :admin do
    resources :users, only: %i[index destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
end