Cloudsdale::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # Which files are going to be precompiled
  # config.assets.precompile = %w(application.css application.js *.ttf *.svg *.woff *.eot *.jst *.png *.jpg .jpeg *.gif *.bmp *.ico)

  # Do not compress assets
  config.assets.compress = false
  
  # Don't fallback to assets pipeline if a precompiled asset is missed
  # config.assets.compile = true

  # Generate digests for assets URLs
  # config.assets.digest = true

  # Expands the lines which load the assets
  config.assets.debug = false
  config.assets.logger = false
  
  config.log_level = :debug
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => "local.cloudsdale.org:3000" }
  config.action_mailer.smtp_settings = { :host => "localhost", :port => 1025 }
  
end

silence_warnings do
  begin
    require 'pry'
    IRB = Pry
  rescue LoadError
  end
end