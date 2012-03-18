source 'http://rubygems.org'

gem 'rails', '3.2.0'

# Database NO-SQL
gem 'mongoid'
gem 'bson_ext', '1.5.2'
gem 'mongo_sessions', :require => "mongo_sessions/rails_mongo_store"
gem 'mongoid_rails_migrations'

gem 'tire',     git: 'git://github.com/karmi/tire.git'
gem 'kaminari', git: 'https://github.com/amatsuda/kaminari.git'

gem 'voteable_mongo'
# gem "hiredis"
# gem "redis", ">= 2.2.0", :require => ["redis", "redis/connection/hiredis"]

# Push notifications
gem 'faye', git: 'git://github.com/faye/faye.git', branch: '0.8.x'

# Production dependencies
gem 'therubyracer'
gem 'execjs'
gem 'scout'

# Markup
gem 'haml'
gem 'haml-rails'
gem 'redcarpet'
gem 'pjax_rails'
gem 'best_in_place'

# Authentication & Authorization
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'cancan'

# Forms
gem 'client_side_validations'

# Storage
gem 'fog', '0.9.0'
gem 'cloudfiles'

# Images
gem 'mini_magick'
gem 'rmagick'
gem 'carrierwave', git: 'git://github.com/jnicklas/carrierwave.git', branch: '0.5-stable'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'imagesize'
gem 'pdf-reader'

# Video
gem 'youtube_it'

# Sound
gem 'soundcloud'

# Others
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'user-agent'

# Assets
gem 'sass'
gem 'sass-rails'
gem 'coffee-script'
gem 'uglifier'
gem 'jquery-rails'
gem 'sprockets'

# Queue
gem 'bunny'
gem 'yajl-ruby', :require => 'yajl'

# Cloudsdale Specific
gem 'urifetch', git: 'git://github.com/Zeeraw/Urifetch.git'

group :development, :test do
  gem 'pry'
  gem 'rails3-generators'
  gem 'rspec-rails'
  gem 'ruby-debug19', :require => 'ruby-debug'
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

group :production do
  gem 'exception_notification'
end

gem 'capistrano'
gem 'capistrano_colors', :require => nil
gem 'unicorn'
gem 'thin'