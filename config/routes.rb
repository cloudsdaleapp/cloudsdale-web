Cloudsdale::Application.routes.draw do
  
  get "notifications/index"

  root to: 'main#index'
  
  match '/logout' => 'sessions#destroy', as: :logout
  match '/login' => 'sessions#new', as: :login
  match '/register' => 'users#new', as: :register
  match '/restore' => "restorations#new", as: :restore
  
  resources :sessions, :only => [:create] do
    get :count, on: :collection
  end
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create,:destroy]
  
  resources :restorations, :only => [:new], :controller => 'restorations'
  
  resources :users, :path_names => { :new => :register }, :except => [:index] do
    get :change_password, on: :member
    put :update_password, on: :member
    resources :subscribers, :only => [:create,:destroy], :controller => 'users/subscribers'
    resources :restorations, :only => [:create,:show], :controller => 'users/restorations'
  end
  
  resources :drops, only: [:create] do
    put '/votes/:value' => 'drops/votes#create', as: :votes
    delete '/vote' => 'drops/votes#destroy', as: :vote
  end
  
  resources :articles, :except => [:index] do
    get :publish, on: :member
    get :promote, on: :member
    post :parse, on: :collection
    resources :comments, :controller => 'articles/comments', :only => [:create,:destroy], :path_names => { :new => :write }
  end
  
  resources :clouds, :except => [:index] do
    resources :members, :controller => 'clouds/members', :only => [:create,:destroy,:index]
    resources :messages, only: [:create,:index], :controller => 'clouds/messages'
  end
  
  resources :notifications, :only => [:index,:show]
  
  resources :tags, :only => [] do
    post :search, on: :collection
  end
  
  resources :search, only: [:create]
  
end