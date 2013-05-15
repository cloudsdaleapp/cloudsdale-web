source 'http://rubygems.org'

gem 'rails', '~> 3.2.13'

# Database NO-SQL
gem 'bson_ext'
gem 'mongoid', '~> 3.1.0'
gem 'moped',   '~> 1.4.0'
gem 'mongoid_rails_migrations', '~> 1.0.0'
gem 'mongoid_fulltext', git: 'git://github.com/Zeeraw/mongoid_fulltext.git'
gem "active_model_serializers", '~> 0.7.0'
gem 'kaminari'
gem 'dalli'

gem "redis", "~> 3.0.1"
gem "hiredis", '~> 0.4.5'

# CANT HAVE ASSETS GROUP!
gem 'sass',           '~> 3.2.1'
gem 'sass-rails',     '~> 3.2.5'
gem 'bootstrap-sass', '~> 2.1.0.0'
gem 'jquery-rails',   '~> 2.0.2'
gem 'coffee-script'
gem 'uglifier'
gem 'sprockets'
gem 'haml_coffee_assets', '~> 1.6.0'
gem 'zurb-foundation',    '~> 4.1.6'
gem 'ace-rails-ap'


# Markup
gem 'slim'
gem 'haml-rails', '~> 0.3.4'
gem 'redcarpet'
gem 'rabl',       '~> 0.6.10'
gem 'roadie'
gem 'simple_form', '~> 2.1.0'

# Frontend
gem 'backbone-on-rails', '~> 0.9.2.0'

# Authentication & Authorization
gem 'redis-rails', '~> 3.2.3'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'pundit', git: 'git://github.com/Zeeraw/pundit.git'
gem 'doorkeeper', '~> 0.6.7'
gem 'strong_parameters', '~> 0.2.1'

# Third-party
gem 'fog'
gem 'cloudfiles', '1.4.18'

# Images
gem 'mini_magick'
gem 'rmagick'
gem 'carrierwave'
gem "carrierwave-mongoid", :git => "git@github.com:Zeeraw/carrierwave-mongoid.git", :branch => "mongoid-3.0", :require => 'carrierwave/mongoid'
gem 'imagesize'
gem 'pdf-reader'

# Video
gem 'youtube_it'

# Others
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'hashr', :require => 'hashr'
gem 'yajl-ruby', :require => 'yajl'
gem 'google-analytics-rails'

# Queueing
gem 'bunny'
gem 'sidekiq', '~> 2.10.1'
gem 'kiqstand', '~> 1.1.0'

# Cloudsdale Specific
gem 'urifetch', git: 'git://github.com/Zeeraw/Urifetch.git'

group :development do
  gem 'gist'
  gem 'foreman'
  gem 'capistrano'
  gem 'capistrano_colors', :require => nil
end

group :development, :test do
  gem 'pry'

  gem 'spork-rails'
  gem 'rspec-rails'

  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

group :test, :darwin, :development do
  gem 'rb-fsevent', :require => false
end

group :test do
  gem "timecop"
  gem 'shoulda-context'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'email_spec'
end

group :production, :assets do
  gem 'therubyracer', '~> 0.11.4'
  gem 'execjs'
end

# Profiling
gem 'newrelic_rpm'
gem 'newrelic_moped'
gem 'ruby-prof'

gem 'unicorn'
gem 'thin'
gem 'sinatra', require: false
