# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    resources :users, only: %i[index show create update] do
      resources :posts, only: %i[index show create update] do
        resources :comments, only: %i[index show create update]
      end
    end
  end
end
