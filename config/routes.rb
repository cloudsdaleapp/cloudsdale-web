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
    get 'disconnect'
    get 'presence'
    resources :messages, :only => [:create]
  end
  
  match '/chat' => "chat#index", as: 'chat'
  
end
