Rails.application.routes.draw do
  devise_for :users

  root "projects#index"
  get "analytics", to: "analytics#index"

  resources :projects do
    # コレクション単位（全体に対するアクション）
    collection do
      post :import         # インポート機能
      get  :analysis       # ← 分析画面（今回追加）
    end

    # メンバー単位（個別IDに対するアクション）
    member do
      delete :destroy      # 明示的な削除（必要ならそのまま残す）
    end
  end
end
