Rails.application.routes.draw do
  devise_for :users

  root "home#index"
  get "analytics", to: "analytics#index"

  resources :users

  resources :projects do
    collection do
      post :import
      get  :analysis
    end
    member do
      delete :destroy
    end
  end
end