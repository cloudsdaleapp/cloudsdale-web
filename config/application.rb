require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Cloudsdale

  def self.config
    @rails_config ||= YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  end

  def self.ytClient
    @ytClient = YouTubeIt::Client.new(:dev_key => config['youtube']['dev_key'])
  end

  def self.redisClient
    @redisClient = Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])
  end

  def self.bunny
    unless @bunny
      @bunny ||= Bunny.new(
        :host => Cloudsdale.config['rabbit']['host'],
        :pass => Cloudsdale.config['rabbit']['pass'],
        :user => Cloudsdale.config['rabbit']['user'])
    end
    unless @bunny.status == :connected
      @bunny.stop
      @bunny.start
    end
    @bunny
  end

  def self.faye_path(type = nil, secure = false)
    host    = (type == :inhouse) ? config['faye']['inhouse_host']  : config['faye']['host']
    port    = (secure == true)   ? config['faye']['secure_port']   : config['faye']['port']
    schema  = (secure == true)   ? config['faye']['secure_schema'] : config['faye']['schema']
    @faye_path = "#{schema}://#{host}:#{port}/#{config['faye']['path']}"
  end

  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

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
    config.middleware.insert_before 0, "AvatarDispatch"

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

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.logger = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # :neckbeard: SOME SERVER STUFF

  end
end
