source 'http://rubygems.org'

gem 'rails', '~> 3.2.2'

# Database NO-SQL
gem 'bson_ext'
gem 'mongoid', :git => 'git://github.com/mongoid/mongoid.git'
gem 'moped', git: 'git://github.com/mongoid/moped.git'
gem 'mongoid_rails_migrations'
gem 'mongoid_fulltext', git: 'git://github.com/Zeeraw/mongoid_fulltext.git'
gem 'voteable_mongo'
gem 'kaminari'

gem 'redis'
gem 'em-hiredis', :require => ["redis", "redis/connection/hiredis"]

# CANT HAVE ASSETS GROUP!
gem 'sass', '~> 3.2.1'
gem 'sass-rails', '~> 3.2.5'
gem 'bootstrap-sass', '~> 2.1.0.0'
gem 'coffee-script'
gem 'uglifier'
gem 'jquery-rails'
gem 'sprockets'
gem 'haml_coffee_assets'


# Markup
gem 'haml'
gem 'haml-rails'
gem 'redcarpet'
gem 'rabl'

# Frontend
gem 'backbone-on-rails'

# Authentication & Authorization
gem 'redis-rails', '~> 3.2.1'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'cancan'

# Forms
gem 'client_side_validations'

# Storage
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

# Sound
gem 'soundcloud'

# Others
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'user-agent'
gem 'hashr', :require => 'hashr'
gem 'yajl-ruby', :require => 'yajl'
gem 'google-analytics-rails'

# AMQP
gem 'bunny'

# Cloudsdale Specific
gem 'urifetch', git: 'git://github.com/Zeeraw/Urifetch.git'

group :development, :test do
  gem 'pry'
  gem 'rails3-generators'
  gem 'rspec-rails'
  # gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'guard-rspec'
  gem 'guard-livereload'
end

group :development do
  gem 'gist'
  gem 'foreman'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

group :production, :assets do
  gem 'therubyracer'
  gem 'execjs'
end

gem 'yard'
gem 'yard-tomdoc', git: 'git://github.com/rubyworks/yard-tomdoc.git'

# Profiling
gem 'newrelic_rpm'
# gem 'rpm_contrib', git: 'git://github.com/newrelic/rpm_contrib.git'

gem 'capistrano'
gem 'capistrano_colors', :require => nil
gem 'unicorn'
gem 'thin'
