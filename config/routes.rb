Cloudsdale::Application.routes.draw do

  namespace "v1", module: "api/v1" do

    resources :sessions, only: [:create]

    resources :donations, only: [:index]

    resources :clouds, only: [:show,:update,:create,:destroy] do

      get   :search,  on: :collection,  as: :search
      get   :recent,  on: :collection,  as: :recent
      get   :popular, on: :collection,  as: :popular

      resources :users, :controller => "clouds/users", only: [:destroy,:update,:index] do

        get :moderators, on: :collection, as: :moderators
        get :online,     on: :collection, as: :online

      end

      resources :drops, :controller => "clouds/drops", only: [:index,:destroy] do

        get :search, on: :collection, as: :search

      end

      resources :bans, :controller => "clouds/bans", only: [:index,:create,:update]

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

    end

    # Post update method for user.
    match "/users/:id" => "users#update", via: :post, as: :user

    match '*path', to: 'exceptions#routing_error'

  end

  # Public: The front page of Cloudsdale.
  root to: 'root#index'

  # Public: Logout path
  match '/logout' => 'sessions#destroy', as: :logout

  # Public: The maintenance page hosted by the Cloudsdale app.
  match '/maintenance' => 'root#maintenance', as: :maintenance

  # Internal: Used by Omniauth to redirect users back from authenticating.
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  # Public: A place to explore Clouds
  get '/explore' => "root#explore", as: :explore
  get '/explore/clouds' => "root#explore", as: :explore_by_resource
  get '/explore/clouds/:scope' => "root#explore", as: :explore_by_resource_and_scope

  # Mobile: Terms and Conditions
  match '/mobile/tncs' => 'mobile#tncs', as: :mobile_tncs

  # Clouds
  match '/clouds/:id_or_short_name' => "clouds#show", as: :cloud

  # Resource: For clouds.
  # resources :clouds, :only => [:show]
  resources :users, :only => [] do
    match "/restore/:token" => "users#restore", as: :restore, on: :collection
  end

  resources :donations, only: [] do
    get :success, on: :collection, as: :success
    get :cancel,  on: :collection, as: :cancel
    post :paypal_ipn, on: :collection, as: :paypal_ipn
  end

  get '/sitemap' => 'sitemap#index', as: :sitemap

  match '/:page_id' => 'pages#show', as: :page

end
