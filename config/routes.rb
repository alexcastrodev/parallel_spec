Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [:index, :show, :create, :update] do
      resources :posts, only: [:index, :show, :create, :update] do
        resources :comments, only: [:index, :show, :create, :update]
      end
    end
  end
end
