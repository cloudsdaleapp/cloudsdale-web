# config/deploy.rb
require "bundler/capistrano"
require 'capistrano_colors'

set :application, "cloudsdale-web"

set :scm,             :git
set :repository,      "git@github.com:IOMUSE/Cloudsdale.git"
set :branch,          "origin/deploy"

set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }

set :rails_env,       "production"
set :deploy_to,       "/opt/app/#{application}"
set :normalize_asset_timestamps, false

set :user,            "deploy"
set :group,           "deploy"
set :use_sudo,        false

role :db,   "ovh.cloudsdale.org"
role :web,  "ovh.cloudsdale.org"
role :app,  "ovh.cloudsdale.org", :primary => true
