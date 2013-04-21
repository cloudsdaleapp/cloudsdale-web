Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{Cloudsdale.config['redis']['host']}:#{Cloudsdale.config['redis']['port']}/0"
    namespace: 'cloudsdale:sidekiq'
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{Cloudsdale.config['redis']['host']}:#{Cloudsdale.config['redis']['port']}/0"
    namespace: 'cloudsdale:sidekiq'
  end
end
