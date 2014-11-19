require "kiqstand"

Sidekiq.configure_server do |config|
  config.redis = { url: Figaro.env.redis_url!, namespace: 'cloudsdale:sidekiq' }
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Figaro.env.redis_url!, namespace: 'cloudsdale:sidekiq' }
end
