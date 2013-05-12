# encoding: utf-8
require 'routing/api_version_mapper'

Cloudsdale::Application.routes.draw do

  api version: 1, subdomain: /(api|www)/ do
    resources :sessions, only: [:create]
    resources :donations, only: [:index]
    resources :clouds, only: [:show,:update,:create,:destroy] do
      get   :search,  on: :collection,  as: :search
      get   :recent,  on: :collection,  as: :recent
      get   :popular, on: :collection,  as: :popular
      resources :users, :controller => "clouds/users", only: [:destroy,:update,:index] do
        get :moderators, on: :collection, as: :moderators
        get :online,     on: :collection, as: :online
      end
      resources :drops, :controller => "clouds/drops", only: [:index,:destroy] do
        get :search, on: :collection, as: :search
      end
      resources :bans, :controller => "clouds/bans", only: [:index,:create,:update]
      namespace :chat, module: 'clouds/chat' do
        resources :messages, only: [:index,:create]
      end
    end
    match "/clouds/:id" => "clouds#update", via: :post, as: :cloud
    resources :users, only: [:show,:create,:update,:index] do
      post "/restore" => 'users#restore', on: :collection, as: :restore
      put "/ban"    => 'users#ban',   on: :member, as: :ban
      put "/unban"  => 'users#unban', on: :member, as: :unban
      put "/accept_tnc" => 'users#accept_tnc', on: :member, as: :accept_tnc
      resources :clouds, :controller => "users/clouds", only: [:index]
    end
    match "/users/:id" => "users#update", via: :post, as: :user
    match '*path', to: 'exceptions#routing_error'
  end

end
