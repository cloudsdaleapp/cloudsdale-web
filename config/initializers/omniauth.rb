Rails.application.config.middleware.use OmniAuth::Builder do

  provider :facebook, Figaro.env.facebook_app_key!, Figaro.env.facebook_app_secret!, scope: 'email,publish_stream'
  provider :twitter, Figaro.env.twitter_consumer_key!, Figaro.env.twitter_consumer_secret!
  provider :github, Figaro.env.github_client_id!, Figaro.env.github_client_secret!, scope: 'user:email'

end
