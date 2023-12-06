Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Splash screen
  root 'splash#index'

  # Categories and Budget Transactions
  resources :categories, only: [:index] do
    resources :budget_transactions, only: [:new, :create]
  end
end