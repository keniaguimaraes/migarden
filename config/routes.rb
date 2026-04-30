Rails.application.routes.draw do
  resources :plants
  resources :care_logs, only: [:create]

  root "plants#index"
end
