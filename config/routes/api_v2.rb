# encoding: utf-8
require 'routing/api_version_mapper'

Cloudsdale::Application.routes.draw do

  api version: 2 do

    root to: 'root#index'

    resource :me, only: [:show,:update], controller: :me do
      member do
        get :auth_token, to: 'me#get_auth_token'
      end
      # resources :networks, only: [:index,:destroy] do
      #   post '/:provider/:uid/share', only: [:create], on: :collection
      # end
      # resources :devices,         only: [:index,:show,:create,:destroy,:update]
      # resources :conversations,   only: [:index,:show,:create,:destroy,:update] do
        # collection do
        #   match :order, via: [:put,:patch]
        # end
      # end
    end

    # resources :spotlights, only: [:index] do
    #   collection do
    #     get :clouds,  to: :index
    #     get :apps,    to: :index
    #   end
    # end

    # resources :apps,   only: [:show] do
    #   collection do
    #     get :search
    #   end
    # end

    resources :clouds, only: [:show,:index] do
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

    match '*path', to: 'root#not_found', via: [:post,:get,:put,:patch,:delete]

  end

end
