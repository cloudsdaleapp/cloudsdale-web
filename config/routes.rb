Cloudsdale::Application.routes.draw do

  namespace "v1", module: "api/v1" do

    resources :sessions, only: [:create]

    resources :clouds, only: [:show,:update,:create,:destroy] do
      
      get   :search,  on: :collection,  as: :search
      get   :recent,  on: :collection,  as: :recent
      get   :popular, on: :collection,  as: :popular
      
      resources :users, :controller => "clouds/users", only: [:destroy,:update,:index] do
        
        get :moderators, on: :collection, as: :moderators
      
      end
      
      resources :drops, :controller => "clouds/drops", only: [:index,:destroy] do
        
        get :search, on: :collection, as: :search
        
      end
      
      namespace :chat, module: 'clouds/chat' do
        resources :messages, only: [:index,:create]
      end
      
    end
    
    # Post update method for cloud.
    match "/clouds/:id" => "clouds#update", via: :post, as: :cloud

    
    resources :users, only: [:show,:create,:update,:index] do
      
      post "/restore" => 'users#restore', on: :collection, as: :restore
      
      put "/ban"    => 'users#ban',   on: :member, as: :ban
      put "/unban"  => 'users#unban', on: :member, as: :unban
      
      put "/accept_tnc" => 'users#accept_tnc', on: :member, as: :accept_tnc
      
      resources :clouds, :controller => "users/clouds", only: [:index]
      
      resources :prosecutions, :controller => "users/prosecutions", only: [:create,:update] do
        put "/vote" => 'users/prosecutions#vote', on: :member, as: :vote
      end
      
    end
    
    # Post update method for user.
    match "/users/:id" => "users#update", via: :post, as: :user
    
    match '*path', to: 'exceptions#routing_error'

  end
  
  # Public: The front page of Cloudsdale.
  root to: 'root#index'
  
  # Public: Logout path
  match '/logout' => 'sessions#destroy', as: :logout
  
  # Public: The error page for not finding a record.
  match '/notfound' => 'root#not_found', as: :not_found
  
  # Public: The error page for server errors.
  match '/error' => 'root#server_error', as: :server_error
  
  # Public: The page for when a user is not authorized to visit another page.
  match '/unauthorized' => 'root#unauthorized', as: :unauthorized
  
  # Public: Custom error page.
  match '/error/:error_id' => 'root#custom_error', as: :custom_error
  
  # Public: The maintenance page hosted by the Cloudsdale app.
  match '/maintenance' => 'root#maintenance', as: :maintenance
  
  # Internal: Used by Omniauth to redirect users back from authenticating.
  match 'auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'
  
  # Public: A place to explore Clouds
  get '/explore' => "root#explore", as: :explore
  
  # Public: A place to explore Clouds
  get '/info' => "root#info", as: :info

  # Mobile: Terms and Conditions
  match '/mobile/tncs' => 'mobile#tncs', as: :mobile_tncs

  # Resource: For clouds.
  resources :clouds, :only => [:show]
  resources :users, :only => [] do
    match "/restore/:token" => "users#restore", as: :restore, on: :collection
  end
  
  get '/sitemap' => 'sitemap#index', as: :sitemap
    
end
