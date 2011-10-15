Cloudsdale::Application.routes.draw do
  
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
  end
  
  namespace :chat do
    resources :messages, :only => [:create,:index], :path_names => { :index => :log, :create => :send }
  end
  
end
