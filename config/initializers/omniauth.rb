Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Cloudsdale.config['facebook']['app_key'].to_s, Cloudsdale.config['facebook']['app_secret'].to_s
  provider :twitter, Cloudsdale.config['twitter']['consumer_key'].to_s, Cloudsdale.config['twitter']['consumer_secret'].to_s
end