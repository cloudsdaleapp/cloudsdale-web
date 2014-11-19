source "http://rubygems.org"
ruby "2.0.0"

gem 'rails', '~> 3.2.14'

# Database NO-SQL
gem 'mongoid', '~> 3.1.4'
gem 'moped', '~> 1.5.0'
gem 'mongoid_token', :git => 'git://github.com/thetron/mongoid_token.git', branch: 'patch/collisions-define-method'
gem 'mongoid_rails_migrations', '~> 1.0.0'
gem 'mongoid_fulltext', '~> 0.6.1'
gem "active_model_serializers", git: 'git://github.com/zeeraw/active_model_serializers.git', branch: 'flatten-polymorphic-id'
gem 'kaminari'
gem 'dalli', '~> 2.6.4'

gem "redis", '~> 3.0.1'
gem "hiredis", '~> 0.4.5'
gem 'redis-rails', '~> 3.2.3'
gem 'redis-store', '1.1.3' # Upgrading this breaks everything

gem 'pry-rails'

gem 'sass', '~> 3.2.9'
gem 'sass-rails', '~> 3.2.6'
gem 'bootstrap-sass', '~> 2.1.0.0'
gem 'jquery-rails', '~> 2.0.2'
gem 'coffee-script'
gem 'uglifier', '~> 2.2.1'
gem 'sprockets', '~> 2.2.1'
gem 'haml_coffee_assets', '~> 1.6.0'
gem 'zurb-foundation', '~> 4.3.1'
gem 'ace-rails-ap'

gem 'ember-rails'
gem 'coffee-rails'
gem 'handlebars-source', '~> 1.0.12'


# Markup
gem 'slim'
gem 'haml-rails',  '~> 0.4'
gem 'redcarpet',   '~> 3.0.0'
gem 'rabl',        '~> 0.6.10'
gem 'roadie',      '~> 2.4.1'
gem 'simple_form', '~> 2.1.0'
gem 'coderay',     '~> 1.0.5'

# Frontend
gem 'backbone-on-rails', '~> 0.9.2.0'

# Authentication & Authorization
gem 'omniauth'
gem 'omniauth-facebook', '~> 1.4.1'
gem 'omniauth-twitter',  '~> 1.0.0'
gem 'omniauth-github',   '~> 1.1.0'
gem 'pundit',            '~> 0.2.1'
gem 'doorkeeper',        '~> 0.6.7'
gem 'strong_parameters', '~> 0.2.1'
gem 'arcane',            '~> 1.1.1'

# Third-party
gem 'fog',        '~> 1.15.0'
# gem 'asset_sync', '~> 1.0.0'
gem 'netdnarws',  '~> 0.2.8'
gem 'cloudfiles', '~> 1.4.18'

# Images
gem 'mini_magick', '~> 3.6.0'
gem 'rmagick', '~> 2.13.3'
gem 'carrierwave', '~> 0.8.0'
gem "carrierwave-mongoid", '~> 0.6.0'
gem 'imagesize', '~> 0.1.1'
gem 'pdf-reader', '~> 1.3.3'

# Video
gem 'youtube_it'

# Others
gem 'bcrypt-ruby',              :require => 'bcrypt'
gem 'hashr',       '~> 0.0.22', :require => 'hashr'
gem 'yajl-ruby',                :require => 'yajl'
gem 'geoip-c',     '~> 0.9.0',  :require => 'geoip'

# Analytics
gem 'google-analytics-rails', '~> 0.0.4'

# Queueing
gem 'bunny'
gem 'sidekiq',  '~> 2.14.0'
gem 'kiqstand', '~> 1.1.0'

# Cloudsdale Specific
gem 'urifetch', git: 'git://github.com/zeeraw/urifetch.git'

group :development do
  gem 'gist',    '~> 4.0.3'
  gem 'foreman', '~> 0.63'
  gem 'capistrano'
  gem 'capistrano_colors', :require => nil
end

group :production do
  gem 'lograge', '~> 0.3.0'
end

group :development, :test do
  gem 'spork-rails'
  gem 'rspec-rails', '~> 2.14.0'

  gem 'guard', '~> 1.8.1'
  gem 'guard-spork', '~> 1.5.1'
  gem 'guard-rspec', '~> 3.0.2'
  gem 'guard-bundler', '~> 1.0.0'

  gem 'database_cleaner', '~> 1.0.1'
  gem 'factory_girl_rails', '~> 4.2.1'
end

group :test, :darwin, :development do
  gem 'rb-fsevent', :require => false
end

group :test do
  gem "timecop"
  gem 'shoulda-context', '~> 1.1.4'
  gem 'shoulda-matchers', '~> 2.3.0'
  gem 'capybara', '~> 2.1.0'
  gem 'email_spec'
end

group :production, :assets do
  gem 'turbo-sprockets-rails3'
  gem 'therubyracer', '~> 0.12.0'
  gem 'execjs'
end

# Profiling
gem 'newrelic_rpm'
gem 'newrelic_moped'
gem 'newrelic-redis'
gem 'ruby-prof'
gem 'skylight'

gem "unicorn"
gem "unicorn-rails"

gem 'sinatra', require: false
