Rails.application.routes.draw do
  # Deviseのルーティングから :registrations を除外（create衝突回避）
  devise_for :users, skip: [:registrations]

  root "home#index" # ログイン後のトップページをルートにする

  get "analytics", to: "analytics#index"
  get "home", to: "home#index"
  get "users/find_by_employee_id", to: "users#find_by_employee_id"

  # 自作のUsersControllerが /users を使えるようになる
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :projects do
    collection do
      post :import
      get  :analysis
      post :destroy_selected
    end
  end
end
