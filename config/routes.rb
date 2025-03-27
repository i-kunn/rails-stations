Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :movies, only: [:index, :show] do
    # 座席表を表示
    get 'reservation', on: :member

    # 座席予約フォーム
    resources :schedules, only: [] do
      resources :reservations, only: [:new]
    end
  end

  # 予約の作成
  resources :reservations, only: [:create]
  namespace :admin do
    resources :movies, only: [:index,:new,:create,:edit,:update,:destroy ]
    resources :schedules, only: [:index, :edit, :update, :destroy]  
  end
  resources :movies, only: [:index, :show]
end

