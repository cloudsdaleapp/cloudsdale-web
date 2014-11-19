ENV["RAILS_ENV"] ||= "production"

cores = if RUBY_PLATFORM.match(/darwin/i)
  `sysctl hw.ncpu | awk '{print $2}'`.chomp
elsif RUBY_PLATFORM.match(/linux/i)
  `nproc`.chomp
else
  (ENV["RAILS_ENV"] == "development") ? 1 : 3
end

listen (ENV["PORT"] || 8080), backlog: 1024

worker_processes Integer(ENV["WEB_CONCURRENCY"] || cores)

if ENV["RAILS_ENV"] == "development"
  timeout 10000
  preload_app false
else
  timeout 15
  preload_app true
  stderr_path "log/unicorn.error.log"
  stdout_path "log/unicorn.access.log"
end

before_fork do |server, worker|
  Signal.trap("TERM") { Process.kill("QUIT", Process.pid) }
end

after_fork do |server, worker|
  Signal.trap("TERM") { Process.kill("QUIT", Process.pid) }
end

