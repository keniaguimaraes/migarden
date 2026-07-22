Rails.application.routes.draw do
  root 'dashboard#index'

  resource :session, only: %i[new create destroy]
  resources :users, only: %i[new create]
  resource :settings, only: %i[show edit update] do
    post :test_whatsapp, on: :collection
    post :trigger_reminders, on: :collection
    post :test_queue_reminder, on: :collection
  end
  resources :alerts, only: [:index]

  resources :plants do
    member do
      patch :mark_as_watered
      patch :mark_as_fertilized
      patch :mark_as_pest_controlled
    end
  end
end
