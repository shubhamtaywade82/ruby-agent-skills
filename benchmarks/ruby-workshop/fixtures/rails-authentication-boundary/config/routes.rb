Rails.application.routes.draw do
  get "/health", to: "health#show"
  get "/dashboard", to: "dashboard#show"
end
