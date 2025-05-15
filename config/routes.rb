Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  get "analytics", to: "analytics#index"

  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :projects


end
