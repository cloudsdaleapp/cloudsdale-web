# config/deploy.rb
require "bundler/capistrano"
require 'capistrano_colors'

set :application, "cloudsdale-web"

set :scm,             :git
set :scm_verbose,     true

set :repository,      'git@github.com:IOMUSE/Cloudsdale.git'
set :remote,          'origin'
set :branch,          'ovh-migration'

set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }

set :rails_env,       "production"
set :deploy_to,       "/opt/app/#{application}"

set :user,            "deploy"
set :group,           "deploy"
set :use_sudo,        false

role :db,   "ovh.cloudsdale.org"
role :web,  "ovh.cloudsdale.org"
role :app,  "ovh.cloudsdale.org", :primary => true

# default_environment["RAILS_ENV"] = 'production'

# default_environment["PATH"]         = "/usr/local/rvm/gems/ruby-1.9.3-p125/bin:/usr/local/rvm/gems/ruby-1.9.3-p125@cloudsdale-web/bin:/usr/local/rvm/rubies/ruby-1.9.3-p125/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
# default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ruby-1.9.3-p125"
# default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ruby-1.9.3-p125:/usr/local/rvm/gems/ruby-1.9.3-p125@cloudsdale-web"
# default_environment["RUBY_VERSION"] = "ruby-1.9.3-p125@cloudsdale-web"

after 'deploy', 'deploy:permissions:correct'

namespace :deploy do

  desc 'Correct permission on all application files to the deploy user.'
  namespace :permissions do
    task :correct, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} chown -R #{user}:#{group} /opt/app/#{application}"
    end
  end

end
