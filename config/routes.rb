Cloudsdale::Application.routes.draw do

  namespace "v1", module: "api/v1" do

    resources :sessions, only: [:create]

    resources :clouds, only: [:show] do
      namespace :chat, module: 'clouds/chat' do
        resources :messages, only: [:index,:create]
      end
    end

    resources :users, only: [:show,:create] do
      resources :clouds, :controller => "users/clouds", only: [:index]
    end

    match '*path', to: 'exceptions#routing_error'

  end
  
  # Public: The front page of Cloudsdale.
  root to: 'root#index'
  
  # Public: The maintenance page hosted by the Cloudsdale app.
  match '/maintenance' => 'root#maintenance', as: :maintenance
  
  # Internal: Used by Omniauth to redirect users back from authenticating.
  match 'auth/:provider/callback' => 'authentications#create'
  
  # Public: A place to explore Clouds
  get '/explore' =>"explore#index", as: :explore
  
  # Resource: For clouds.
  resources :clouds, :only => [:show]
  
end