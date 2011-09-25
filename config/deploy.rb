require 'capistrano_colors'
require "bundler/capistrano"
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
require "rvm/capistrano"                                # Load RVM's capistrano plugin.

set :application, "cloudsdale.org"


set :rvm_bin_path, "/usr/local/rvm/bin"
set :rvm_ruby_string, '1.9.2'
set :rvm_type, :system
set :normalize_asset_timestamps, false

set :repository,  "git@github.com:Zeeraw/Cloudsdale.git"

set :scm, :git
default_run_options[:pty] = true

set :user, 'root'
set :password, 'CloudsdaleomU46Su5R'
set :use_sudo, false
set :deploy_to, '/opt/app'

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
           # Web01        #Web02
role :web, "50.57.125.171"                  
role :app, "50.57.125.171"                  
role :db,  "50.57.125.171", :primary => true 

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :update do
    run "cd /opt/app;#{try_sudo} git pull"
    run "cd /opt/app;#{try_sudo} bundle install"
    run "cd /opt/app;#{try_sudo} rake db:migrate RAILS_ENV=production"
    run "cd /opt/app;#{try_sudo} rake assets:precompile RAILS_ENV=production"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd /opt/app;#{try_sudo} touch tmp/restart.txt"
  end
end