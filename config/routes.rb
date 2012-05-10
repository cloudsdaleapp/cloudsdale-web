Cloudsdale::Application.routes.draw do

  namespace "v1", module: "api/v1" do

    resources :sessions, only: [:create]

    resources :clouds, only: [:show] do
      namespace :chat, module: 'clouds/chat' do
        resources :messages, only: [:index,:create]
      end
    end

    resources :users, only: [:show,:create] do
      post restore: 'users/restore', on: :collection, as: :restore
      resources :clouds, :controller => "users/clouds", only: [:index]
    end

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
  get '/explore' => "explore#index", as: :explore
  
  # Resource: For clouds.
  resources :clouds, :only => [:show]

  
end