# Be sure to restart your server when you modify this file.

# Cloudsdale::Application.config.session_store :mongo_store, key: '_cloudsdale_session', collection: lambda { Mongoid.master.collection('sessions') }

Cloudsdale::Application.config.session_store :redis_store,
  :servers => {
    :host => Cloudsdale.config['redis']['host'],
    :port => Cloudsdale.config['redis']['port'],
    :db => 0,
    :namespace => 'cloudsdale:sessions'
  }


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Cloudsdale::Application.config.session_store :active_record_store
