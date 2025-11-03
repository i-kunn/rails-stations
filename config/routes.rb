Rails.application.routes.draw do
  # サイトステータス確認用（ヘルスチェック）
  get 'up' => 'rails/health#show', as: :rails_health_check
  post '/users', to: 'users#create', as: :user_registration

  devise_for :users
  root to: 'movies#index' # ← 適当なトップページに設定
  # 映画一覧・詳細
  resources :movies, only: %i[index show] do
    # 映画ごとの予約ページ表示（独自ルート）
    get 'reservation', on: :member

    # 映画 → スケジュール → 予約フォーム（new）
    resources :schedules, only: [] do
      resources :reservations, only: [:new]
    end
  end

  # 予約作成・キャンセル + 確認/完了ページ
  resources :reservations, only: %i[create destroy] do
    member do
      get :confirm_cancel # /reservations/:id/confirm_cancel
    end
    collection do
      get :cancelled # /reservations/cancelled
    end
  end

  # 管理画面用ルーティング
  namespace :admin do
    resources :movies, only: %i[index new create edit update destroy]
    resources :schedules, only: %i[index edit update destroy]
    resources :reservations
  end
end
