# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "production"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 4

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/.sock", :backlog => 64
listen 80, :tcp_nopush => true

# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
# user "unprivileged_user", "unprivileged_group"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/opt/app/current" # available in 0.94.0+
pid "/opt/pids/unicorn.pid"

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy

user 'deploy', 'web'

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

#stdeer_path "/opt/logs/unicorn.stderr.log"
#stdout_path "/opt/logs/unicorn.stderr.log"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
# preload_app true
# GC.respond_to?(:copy_on_write_friendly=) and
#   GC.copy_on_write_friendly = true