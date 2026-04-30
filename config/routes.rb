Rails.application.routes.draw do
  resources :plants do
    resources :care_parameters, only: [:index, :new, :create, :destroy]
  end
  resources :care_logs, only: [:create]

  root "plants#index"
end
