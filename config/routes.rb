Cloudsdale::Application.routes.draw do
  
  get "notifications/index"

  root to: 'main#index'
  
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  
  resources :sessions, :only => [:create,:index] do
    get :count, on: :collection
  end
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create,:destroy]
  
  resources :users, :path_names => { :new => :register } do
    get :restore, on: :collection
    resources :subscribers, :only => [:create,:destroy], :controller => 'users/subscribers'
  end
  
  resources :notifications, :only => [:index,:show]
  
  namespace :chat do
    resources :rooms, :only => [:index] do
      get :subscribed, on: :collection
      get :form, on: :member
      resources :messages, :only => [:create,:index], :controller => 'rooms/messages'
    end
  end
  
end