Cloudsdale::Application.routes.draw do
  
  get "notifications/index"

  root to: 'main#index'
  
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/register' => 'users#new', :as => :register
  
  resources :sessions, :only => [:create,:index] do
    get :count, on: :collection
  end
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create,:destroy]
  
  resources :users, :path_names => { :new => :register } do
    get :restore, on: :collection
    resources :subscribers, :only => [:create,:destroy], :controller => 'users/subscribers'
  end
  
  resources :articles, :except => [:index] do
    get :publish, on: :member
    get :promote, on: :member
    resources :comments, :controller => 'articles/comments', :only => [:create,:destroy], :path_names => { :new => :write }
  end
  
  resources :clouds, :except => [:index] do
    resources :members, :controller => 'clouds/members', :only => [:create,:destroy]
  end
  
  resources :notifications, :only => [:index,:show]
  
  resources :tags, :only => [] do
    post :search, on: :collection
  end
  
  namespace :chat do
    resources :rooms, :only => [:index] do
      get :subscribed, on: :collection
      get :form, on: :member
      resources :messages, :only => [:create,:index], :controller => 'rooms/messages'
    end
  end
  
end