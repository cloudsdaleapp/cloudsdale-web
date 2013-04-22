require 'kiqstand'

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{Cloudsdale.config['redis']['host']}:#{Cloudsdale.config['redis']['port']}/0",
    namespace: 'cloudsdale:sidekiq'
  }

  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
  end

end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{Cloudsdale.config['redis']['host']}:#{Cloudsdale.config['redis']['port']}/0",
    namespace: 'cloudsdale:sidekiq'
  }
end
