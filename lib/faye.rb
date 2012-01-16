require 'rubygems'
require 'faye'
require 'eventmachine'
require 'yaml'
require 'mongo'
require 'redis'

$LOAD_PATH << File.dirname(__FILE__)

ENVIRONMENT = ARGV[0]

if ENVIRONMENT == 'development'
  require 'pry'
end

config = YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")[ENVIRONMENT]
db_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/mongoid.yml")[ENVIRONMENT]

FAYE_TOKEN = config['faye']['token']

if ENVIRONMENT == 'production'
  hosts = db_config["hosts"]
  db = Mongo::ReplSetConnection.new(hosts.pop, hosts.pop, hosts.pop, read: :secondary, refresh_mode: :sync).db(db_config["database"])
else
  db = Mongo::Connection.new(db_config["host"],db_config["port"].to_i).db(db_config["database"])
end
db.authenticate(db_config["username"],db_config["password"])

redis = Redis.new(host: config['redis']['chat']['host'], port: config['redis']['chat']['port'].to_i)

autoload :ServerAuth, "faye/server_auth"
autoload :ClientAuth, "faye/client_auth"


module Faye
  class Server
    def make_response(message)
      response = {}
      %w[id clientId channel error ext].each do |field|
        if message[field]
          response[field] = message[field]
        end
      end
      response['successful'] = !response['error']
      response
    end
  end
end

###########################

server = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
server.add_extension(ServerAuth.new(db,redis,server))

EM.run do
  # Server Setup
  thin = Rack::Handler.get('thin')
  thin.run(server, :Port => config['faye']['port'].to_i) {}
  client = server.get_client
  client.add_extension(ClientAuth.new)
  
  server.bind(:unsubscribe) do |client_id, channel|
    if channel =~ %r{^/cloud/(.*)/presence} and client_id != client.client_id
      # Fetches the user id from the client
      user_id = redis.hget("clients.#{client_id}.user","user_id") if redis.exists("clients.#{client_id}.user")
      unless user_id.nil?
        client.publish channel, { status: 'leave', user_id: user_id }
      end
    end
  end

end
