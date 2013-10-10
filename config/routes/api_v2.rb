# encoding: utf-8
require 'routing/api_version_mapper'

Cloudsdale::Application.routes.draw do

  api version: 2 do

    root to: 'root#index'

    match '/me/session',                    to: 'me#get_session',     via: :get,           as: :session
    match '/me/auth_token',                 to: 'me#get_auth_token',  via: :get,           as: :auth_token

    resource :me, only: [:show,:update], controller: :me do

      # resources :networks, only: [:index,:destroy] do
      #   post '/:provider/:uid/share', only: [:create], on: :collection
      # end
      # resources :devices,         only: [:index,:show,:create,:destroy,:update]
      # resources :conversations, only: [:show], path: 'convos' do
      #   # collection do
      #   #   match :order, via: [:put,:patch]
      #   # end
      # end
    end

    resources :handles, only: [:show], path: 'handle'

    resources :conversations, only: [:create, :update, :destroy], path: 'me/convos', as: :convos do
      resources :messages, only: [:index, :create, :update, :destroy]
      get :lookup,          on: :collection, action: :lookup, as: nil
      get :'lookup/:topic', on: :collection, action: :lookup, as: :lookup
    end

    resources :spotlights, only: [:index, :show] do
      collection do
        get '/:category', to: 'spotlights#index'
      end
    end

    # resources :apps,   only: [:show] do
    #   collection do
    #     get :search
    #   end
    # end

    resources :messages, only: [:index, :create, :update, :destroy] do
      # collection do
      #   get :search
      # end
    end

    resources :clouds,   only: [:show,:index] do
      collection do
        get :search
      end
    end

    resources :users,  only: [:show,:index] do
      collection do
        get :search
      end
    end

    # resources :registrations, only: [:create,:update]

    match 'lookup/:handle', to: 'root#lookup', via: [:get]

    match '*path', to: 'root#not_found', via: [:post,:get,:put,:patch,:delete,:options]

  end

end
