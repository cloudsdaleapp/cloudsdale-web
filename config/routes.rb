Cloudsdale::Application.routes.draw do
  
  root to: 'main#index'
  
  resources :sessions, :only => [:new,:create,:destroy]
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create,:destroy]
  
  resources :users, :path_names => { :new => :register } do
    get :restore, on: :collection
  end
  
  resources :ponies

  namespace :chat do
    get 'connect'
    resources :messages, :only => [:create]
    resources :rooms, :only => [] do
      get 'connect', :on => :member
      get 'disconnect', :on => :member
      get 'presence', :on => :member
    end
  end
  
  match '/chat' => "chat#index", as: 'chat'
  
end
