Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post :sign_in, to: "sessions#create"
      resources :sessions, only: :destroy

      resources :sleep_records
      resources :users, only: [ :index, :show ] do
        member do
          post :follow
          delete :unfollow
          get :followers
          get :following
          get :sleep_records
        end
      end

      get :feeds, to: "feeds#index"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
