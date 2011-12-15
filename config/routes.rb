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
  
  resources :articles, :except => [:index] do
    get :publish, on: :member
    get :promote, on: :member
    post :parse, on: :collection
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
  
  resources :search, only: [:create]
  
end