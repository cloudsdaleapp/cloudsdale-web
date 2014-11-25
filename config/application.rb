require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "active_support/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(development test))
end

module Cloudsdale

  def self.bunny
    @bunny ||= Bunny.new(Figaro.env.amqp_url!)
    @bunny.start unless @bunny.connected?
    return @bunny
  end

  def self.cdn
    @cdn ||= NetDNARWS::NetDNA.new(
      Figaro.env.cdn_alias!,
      Figaro.env.cdn_key!,
      Figaro.env.cdn_secret!
    )
  end

  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.after_initialize do
      Cloudsdale.bunny.queue "faye",
        auto_delete: false,
        durable: true

      Cloudsdale.bunny.queue "drops",
        auto_delete: false,
        durable: true
    end

    config.generators do |g|
      config.sass.preferred_syntax = :sass
      g.test_framework = :rspec
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/concerns)
    config.autoload_paths += %W(#{config.root}/app/serializers)
    config.autoload_paths += %W(#{config.root}/lib/validators)
    config.autoload_paths += %W(#{config.root}/lib/middleware)

    # Middlewares
    config.middleware.insert_after("Rack::Lock", "AvatarDispatch")
    # config.middleware.insert_before(0, "AvatarDispatch")

    # Multiple Route Files
    config.paths["config/routes"] += Dir[Rails.root.join('config', 'routes', '*.rb').to_s]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Stockholm'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Configure HamlCoffee to so it does not escape HTML
    config.hamlcoffee.escapeHtml = false
    config.handlebars.templates_root = 'web/templates'

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.logger = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # :neckbeard: SOME SERVER STUFF

  end
end
