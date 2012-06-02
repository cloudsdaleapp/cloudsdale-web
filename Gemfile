source 'http://rubygems.org'

# gem 'linecache19', '0.5.13', :path => "~/.rvm/gems/ruby-1.9.3-p#{RUBY_PATCHLEVEL}/gems/linecache19-0.5.13/"
# gem 'ruby-debug-base19', '0.11.26', :path => "~/.rvm/gems/ruby-1.9.3-p#{RUBY_PATCHLEVEL}/gems/ruby-debug-base19-0.11.26/"
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'rails', '3.2.2'

# Database NO-SQL
gem 'mongoid'
gem 'bson_ext', '1.5.2'
gem 'mongoid_rails_migrations'
gem 'mongoid_fulltext'
gem 'voteable_mongo'
gem 'kaminari'

gem 'redis'
gem 'em-hiredis', :require => ["redis", "redis/connection/hiredis"]

# CANT HAVE ASSETS GROUP!
gem 'sass', '~> 3.2.0.alpha'
gem 'sass-rails', '~> 3.2.5'
gem 'bootstrap-sass'
gem 'coffee-script'
gem 'uglifier'
gem 'jquery-rails'
gem 'sprockets'
gem 'haml_coffee_assets'


# Markup
gem 'haml'
gem 'haml-rails'
gem 'redcarpet'
gem 'pjax_rails'
gem 'best_in_place'
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
gem 'hashr', :require => 'hashr'
gem 'yajl-ruby', :require => 'yajl'

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
  gem 'exception_notification'
  gem 'therubyracer'
  gem 'execjs'
end

gem 'yard'
gem 'yard-tomdoc', git: 'git://github.com/rubyworks/yard-tomdoc.git'

gem 'capistrano'
gem 'capistrano_colors', :require => nil
gem 'unicorn'
gem 'thin'