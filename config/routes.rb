Cloudsdale::Application.routes.draw do

  namespace :admin do
    match '/',  to: 'root#index',  via: :get,  as: :root
  end

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

    # To do a form encoded request to update clouds we need to add a specific
    # POST request to the clouds update path.
    match "/clouds/:id" => "clouds#update", via: :post, as: :cloud


    resources :users, only: [:show,:create,:update,:index] do

      post "/restore" => 'users#restore', on: :collection, as: :restore

      put "/ban"    => 'users#ban',   on: :member, as: :ban
      put "/unban"  => 'users#unban', on: :member, as: :unban

      put "/accept_tnc" => 'users#accept_tnc', on: :member, as: :accept_tnc

      resources :clouds, :controller => "users/clouds", only: [:index]

    end

    # To do a form encoded request to update users we need to add a specific
    # POST request to the users update path.
    match "/users/:id" => "users#update", via: :post, as: :user

    # The API has it's own 404 response. This is here so that 404's will not
    # be picked up by the website catch-all response and can return with
    # Cloudsdale API's specific JSON response wrapper.
    match '*path', to: 'exceptions#routing_error'

  end

  # The root path where users will land when entering our url.
  root to: 'root#index'

  # Use this endpoint to end a users session through the webapp.
  match '/logout' => 'sessions#destroy', as: :logout

  # A maintenence page hosted by the Cloudsdale app itself, this is rarely
  # used as Cloudsdale never has scheduled maintenences.
  match '/maintenance' => 'root#maintenance', as: :maintenance

  # Omniauth routes to connect users to different services oAuth2 services
  # like Twitter and Facebook. This has nothing to do with Cloudsdale's own
  # oAuth2 provider.
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  # The explore page is devided up in to three tiers where the front-end will
  # automatically take you up to the default tier if you're requesting it at
  # at a lower level.
  get '/explore' => "root#explore", as: :explore
  get '/explore/clouds' => "root#explore", as: :explore_by_resource
  get '/explore/clouds/:scope' => "root#explore", as: :explore_by_resource_and_scope

  # Mobile terms and conditions page, this route will most certenly be deprecated.
  match '/mobile/tncs' => 'mobile#tncs', as: :mobile_tncs

  # Path straight to a Cloud, you can supply either the clouds ID or it's shorthand.
  match '/clouds/:id_or_short_name' => "clouds#show", as: :cloud

  resources :users, :only => [] do
    match "/restore/:token" => "users#restore", as: :restore, on: :collection
  end

  # PayPal Donation endpoints for PayPal own IPN to automatically update payments
  # received by by our users to run scrips that connect the two.
  resources :donations, only: [] do
    get :success, on: :collection, as: :success
    get :cancel,  on: :collection, as: :cancel
    post :paypal_ipn, on: :collection, as: :paypal_ipn
  end

  # The XML sitemap that google uses to index the Cloudsdale site. Currently
  # lists all know pages as well as automatically listing all public Clouds.
  get '/sitemap' => 'sitemap#index', as: :sitemap

  # A way to add a page through the pages controller without creating a specific
  # route for it. This NEEDS to be last so that it's a "catch all" route.
  match '/:page_id' => 'pages#show', as: :page

end
