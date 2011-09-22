Cloudsdale::Application.routes.draw do

  root to: 'main#index'
  
  resources :sessions, :only => [:new,:create,:destroy]
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  
  match 'auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:create]
  
  resources :users, :only => [:new,:create,:edit,:update], :path_names => { :new => :register }
  
  resources :ponies

end
