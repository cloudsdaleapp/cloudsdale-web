Cloudsdale::Application.routes.draw do
  
  mount Resque::Server.new, :at => "/resque"

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
    resources :messages, :only => [:create]
  end
  
  match '/chat' => "chat#index", as: 'chat'
  
end
