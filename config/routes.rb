require 'sidekiq/web'
require "constraints/admin_constraints"
require 'routing/site_mapper'

Cloudsdale::Application.routes.draw do

  # Use this endpoint to end a users session through the webapp.
  get  '/logout' => 'sessions#destroy', as: :logout
  get  '/login'  => 'sessions#new',     as: :login
  post '/login'  => 'sessions#create',  as: :login

  get  '/register' => 'registrations#new',    as: :register
  post '/register' => 'registrations#create', as: :register

  get  '/register/verify' => 'registrations#edit',   as: :register_verification
  put  '/register/verify' => 'registrations#update', as: :register_verification

  use_doorkeeper do
    controllers      authorizations: 'oauth/authorizations'
    skip_controllers :applications, :authorized_applications
  end

  # Omniauth routes to connect users to different services oAuth2 services
  # like Twitter and Facebook. This has nothing to do with Cloudsdale's own
  # oAuth2 provider.
  match '/auth/github/callback'    => 'authentications#github'
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure'            => 'authentications#failure'

  scope :web, constraints: { subdomain: /www/ } do

    # The root path where users will land when entering our url.
    root to: 'root#index'

    namespace :admin do
      match '/',  to: 'root#index',  via: :get,  as: :root
      resources :dispatches, only: [:index,:show,:create,:update]
    end

    mount Sidekiq::Web,   at: '/admin/workers',   constraints: AdminConstraints.new

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

    # Endpoints for email links.
    resources :emails, only: [], path: :email do
      get :unsubscribe, on: :member
      get :verify,      on: :member
    end

    # The XML sitemap that google uses to index the Cloudsdale site. Currently
    # lists all know pages as well as automatically listing all public Clouds.
    get '/sitemap' => 'sitemap#index', as: :sitemap

    # A way to add a page through the pages controller without creating a specific
    # route for it. This NEEDS to be last so that it's a "catch all" route.
    match '/:page_id' => 'pages#show', as: :page

  end

  site :developer, subdomain: 'dev' do
    root to: 'root#index'

    resources :docs, only: [:index,:show]

    resources :applications, path: 'apps', path_names: { edit: 'settings' } do
      post  '/new'      => 'applications#create', on: :collection, as: :new
      match '/settings' => 'applications#update', on: :member, as: :edit, via: [:put,:patch]
    end

    match '*path', to: 'root#not_found'
  end

end
