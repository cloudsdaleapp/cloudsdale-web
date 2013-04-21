# config/deploy.rb
require "bundler/capistrano"
require 'sidekiq/capistrano'
require 'capistrano_colors'

set :application,   "cloudsdale-web"
set :ruby_version,  "ruby-1.9.3-p125"

set :rake, "#{rake} --trace"

set :scm,             :git
set :scm_verbose,     true

set :repository,      'git@github.com:IOMUSE/Cloudsdale.git'
set :remote,          'origin'
set :branch,          'master'

set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }

set :rails_env,       "production"
set :deploy_to,       "/opt/app/#{application}"

set :user,            "deploy"
set :group,           "deploy"
set :use_sudo,        false

# Sidekiq
set :sidekiq_cmd,       "#{bundle_cmd} exec sidekiq"
set :sidekiqctl_cmd,    "#{bundle_cmd} exec sidekiqctl"
set :sidekiq_timeout,   10
set :sidekiq_role,      :app
set :sidekiq_pid,       "/var/run/sidekiq.pid"
set :sidekiq_processes, 8

role :db,   "www.cloudsdale.org"
role :web,  "www.cloudsdale.org"
role :app,  "www.cloudsdale.org", :primary => true

after 'deploy', 'deploy:permissions:correct'
after 'deploy:create_symlink', 'deploy:assets:upload'

# Default Environment
default_environment["RAILS_ENV"]    = rails_env
default_environment["PATH"]         = "/usr/local/rvm/gems/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@#{application}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/#{ruby_version}"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/#{ruby_version}@#{application}:/usr/local/rvm/gems/#{ruby_version}@global"
default_environment["RUBY_VERSION"] = "#{ruby_version}"

namespace :deploy do

  desc 'Correct permission on all application files to the deploy user.'
  namespace :permissions do
    task :correct, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} chown -R #{user}:#{group} /opt/app/#{application}"
    end
  end

  namespace :assets do
    desc "Deploy assets to Rackspace CloudFiles."
    task :upload, :roles => :app, :except => { :no_release => true }, :only => { :primary => true } do
      run "cd #{deploy_to}/current && /usr/bin/env rake assets:upload RAILS_ENV=#{rails_env} SHARED_PATH=#{shared_path}"
    end
  end

  namespace :updater do
    desc "Sends an update notification to all web clients."
    task :web, :roles => :app, :except => { :no_release => true }, :only => { :primary => true } do |args,t|
      message = ENV['message'] ? ENV['message'] : "Some things were probably fixed"
      run "cd #{current_path} ; #{rake} RAILS_ENV=#{rails_env} SHARED_PATH=#{shared_path} updater:web['#{message}']"
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "kill -s USR2 `cat /var/run/unicorn/web.pid`"
  end

  desc "Start unicorn"
  task :start, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -E production -D"
  end

  desc "Stop unicorn"
  task :stop, :roles => :web, :except => { :no_release => true } do
    run "kill -s QUIT `cat /var/run/unicorn/web.pid`"
  end

end
