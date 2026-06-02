Rails.application.routes.draw do
  root "dashboard#index"

  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
  resource :settings, only: [:show, :edit, :update]
  resources :alerts, only: [:index]

  resources :plants do
    member do
      patch :mark_as_watered
      patch :mark_as_fertilized
      patch :mark_as_pest_controlled
    end
  end
end
