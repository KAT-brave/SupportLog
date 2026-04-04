Rails.application.routes.draw do
  root "home#index"

  resource :registration, only: %i[new create]
  resource :session

  namespace :admin do
    resources :users, only: %i[index destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
end