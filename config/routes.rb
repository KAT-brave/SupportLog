Rails.application.routes.draw do
  root "home#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resource :registration, only: %i[new create]
  resource :session

  resources :passwords, param: :token, only: %i[new create edit update]

  resources :inquiries

  namespace :admin do
    resources :users, only: %i[index destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
end
