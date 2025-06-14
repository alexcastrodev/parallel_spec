# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :users, only: %i[index show create update] do
      resources :posts, only: %i[index show create update] do
        resources :comments, only: %i[index show create update]
      end
    end
  end
end
