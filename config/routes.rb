Rails.application.routes.draw do
  get "inquiries/index"
  get "inquiries/show"
  get "inquiries/new"
  get "inquiries/create"
  get "inquiries/edit"
  get "inquiries/update"
  root "home#index"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resource :registration, only: %i[new create]
  resource :session

  resources :inquiries do
    member do
      patch :soft_delete
    end
  end

  namespace :admin do
    resources :users, only: %i[index destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
end