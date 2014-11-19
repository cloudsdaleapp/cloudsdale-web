require "pry"

lock "3.2.1"

set :application, "www.cloudsdale.org"

set :keep_releases, 5

set :repo_url, "git@github.com:cloudsdaleapp/cloudsdale.git"
set :deploy_to, "~/apps/#{ fetch(:application) }"
set :pty, true

set :linked_files, %w(
  config/sidekiq.yml
  config/mongoid.yml
  config/newrelic.yml
)

set :linked_dirs, %w{
  bin
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  vendor/bundle
  public/system
}

set :default_env, {
  path: "/opt/ruby/bin:$PATH"
}

namespace :deploy do

  desc "Set up application directories"
  task :setup do
    on roles(:app), in: :sequence do
      execute :mkdir, "-p", shared_path.join("config")
      execute :touch, fetch(:linked_files).map {|f|shared_path.join(f)}.join(" ")
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

end
