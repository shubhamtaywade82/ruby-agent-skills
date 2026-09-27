Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resource :session, only: %i[new create destroy]
  resources :notes, only: %i[index create]

  # Lets browser tests skip the sign-in form.
  post "__test__/login" => "test_sessions#create"

  root "notes#index"
end
