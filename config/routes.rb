Rails.application.routes.draw do
  root 'dashboard#index'

  post 'dashboard/water_all', to: 'dashboard#water_all', as: :water_all_dashboard

  resource :session, only: %i[new create destroy]
  resources :users, only: %i[new create]
  resource :settings, only: %i[show edit update] do
    post :test_telegram, on: :collection
    post :connect_telegram, on: :collection
    post :trigger_reminders, on: :collection
  end
  get '/calendar', to: 'calendar#index', as: :calendar
  get '/alertas', to: redirect('/calendar')

  resources :plants do
    member do
      patch :mark_as_watered
      patch :mark_as_fertilized
      patch :mark_as_pest_controlled
    end
  end
end
