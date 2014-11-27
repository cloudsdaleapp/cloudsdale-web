ENV["RAILS_ENV"] ||= "production"

total_workers = if RUBY_PLATFORM.match(/darwin/i)
  `sysctl hw.ncpu | awk '{print $2}'`.chomp
elsif RUBY_PLATFORM.match(/linux/i)
  `nproc`.chomp
else
  (ENV["RAILS_ENV"] == "development") ? 1 : 3
end

listen (ENV["PORT"] || 8080), backlog: 1024
worker_processes Integer(ENV["WEB_CONCURRENCY"] || total_workers)

if ENV["RAILS_ENV"] == "development"
  timeout 10000
  preload_app false
else
  timeout 15
  preload_app true
  pid "/tmp/unicorn.pid"
end

before_fork do |server, worker|
  old_pid = "#{ server.config[:pid] }.old"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  Signal.trap("TERM") { Process.kill("QUIT", Process.pid) }
end

after_fork do |server, worker|
  Signal.trap("TERM") { Process.kill("QUIT", Process.pid) }
  ::NewRelic::Agent.after_fork(force_reconnect: true) if defined?(Unicorn) && ENV["RAILS_ENV"] == "production"
end

