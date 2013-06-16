# encoding: utf-8
require 'routing/api_version_mapper'

Cloudsdale::Application.routes.draw do

  api version: 2 do
    root to: 'root#index'
    # resource :session, only: [:create]
    resource :me, only: [:show], controller: :me do
      get :auth_token, on: :member
    end

    match '*path', to: 'root#not_found', via: [:post,:get,:put,:patch,:delete]
  end

end
