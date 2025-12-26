# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # Home
  root "home#index"
  get "about", to: "home#about"
  get "help", to: "home#help"

  # Forms (individual access)
  resources :forms, only: [:index, :show, :update], param: :id do
    member do
      get :preview
      get :download
    end
  end

  # Workflows (guided wizard)
  resources :workflows, only: [:index, :show], param: :id do
    member do
      patch :step
      post :advance
      post :back
      get :complete
    end
  end

  # Submissions (user's saved forms)
  resources :submissions, only: [:index, :show, :destroy] do
    member do
      get :pdf
      get :download_pdf
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
