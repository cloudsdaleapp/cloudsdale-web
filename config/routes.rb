Cloudsdale::Application.routes.draw do

  namespace "v1", module: "api/v1", constraints: { subdomain: /api|api\.local/i } do


    match '*path', to: 'exceptions#routing_error'

  end
  
  root to: 'main#index'
  
  match '/maintenance' => 'main#maintenance', as: :maintenance
  match '/logout' => 'sessions#destroy', as: :logout
  match '/login' => 'sessions#new', as: :login
  match '/register' => 'users#new', as: :register
  match '/restore' => "restorations#new", as: :restore
  
  get '/explore' =>"explore#index", as: :explore
  resources :sessions, :only => [:create] do
    get :count, on: :collection
  end
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create,:destroy]
  
  resources :restorations, :only => [:new], :controller => 'restorations'
  
  resources :users, :path_names => { :new => :register }, :except => [:index] do
    get :change_password, on: :member
    put :update_password, on: :member
    put :accept_tnc, on: :member
    resources :subscribers, :only => [:create,:destroy], :controller => 'users/subscribers'
    resources :restorations, :only => [:create,:show], :controller => 'users/restorations'
    resources :drops, only: [:create], :controller => 'users/drops'
  end
  
  resources :drops, only: [:create] do
    get :extras, on: :member
    get :search, on: :collection
    put '/votes/:value' => 'drops/votes#create', as: :votes
    delete '/vote' => 'drops/votes#destroy', as: :vote
    resources :reflections, only: [:create,:destroy], controller: 'drops/reflections' do
      put '/votes/:value' => 'drops/reflections/votes#create', as: :votes
      delete '/vote' => 'drops/reflections/votes#destroy', as: :vote
    end
  end
  
  resources :faqs, only: [:index,:create,:destroy,:update] do
    post :sort_figures, on: :collection
  end
  
  resources :clouds, :except => [:index] do
    put :feature, on: :member
    resources :members, :controller => 'clouds/members', :only => [:create,:destroy,:index]
    resources :messages, only: [:create,:index], :controller => 'clouds/messages'
    resources :drops, only: [:create], :controller => 'clouds/drops'
  end
  
  resources :notifications, :only => [:index,:show]
    
  resources :admin, only: [:index] do
    collection do
      post :statistics
    end
  end
  
end