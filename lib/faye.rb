require 'rubygems'
require 'faye'
require 'eventmachine'
require 'yaml'
require 'mongo'
require 'net/http'
require 'redis'

$LOAD_PATH << File.dirname(__FILE__)

ENVIRONMENT = ARGV[0]

config = YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")[ENVIRONMENT]
db_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/mongoid.yml")[ENVIRONMENT]

FAYE_TOKEN = config['faye']['token']

if ENVIRONMENT == 'production'
  db = Mongo::ReplSetConnection.new(db_config["hosts"], read: :secondary, refresh_mode: :sync).db(db_config["database"])
else
  db = Mongo::Connection.new(db_config["host"],db_config["port"].to_i).db(db_config["database"])
end
db.authenticate(db_config["username"],db_config["password"])

redis = Redis.new(host: config['redis']['chat']['host'], port: config['redis']['port']['port'].to_i)

autoload :ServerAuth, "faye/server_auth"
autoload :ClientAuth, "faye/client_auth"
autoload :ClientRegister, "faye/client_register"

#endpoint = "#{config['faye']['schema']}://#{config['faye']['host']}:#{config['faye']['port']}/#{config['faye']['path']}"

server = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
server.add_extension(ServerAuth.new(db,redis))

client = server.get_client
client.add_extension(ClientAuth.new)

EM.run do
  # Server Setup
  thin = Rack::Handler.get('thin')
  thin.run(server, :Port => config['faye']['port'].to_i) {}
  
  server.bind(:subscribe) do |client_id, channel|
    if channel =~ %r{^/cloud/(.*)/presence}
      # Fetches the user id from the client
      user_id = redis.get("fayeclients.#{client_id}.user_id")
      user_data = redis.hgetall("users.#{user_id}")
      client.publish channel, { status: 'join', user_id: user_id, data: user_data }
    end
  end
  
  server.bind(:unsubscribe) do |client_id, channel|
    if channel =~ %r{^/cloud/(.*)/presence}
      # Fetches the user id from the client
      user_id = redis.get("fayeclients.#{client_id}.user_id")
      client.publish channel, { status: 'leave', user_id: user_id }
    end
  end

end
