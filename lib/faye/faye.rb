require 'rubygems'
require 'faye'
require 'yaml'

ENVIRONMENT = ARGV[0]

config = YAML.load_file("#{File.dirname(__FILE__)}/../../config/config.yml")[ENVIRONMENT.to_s]

if ENVIRONMENT == 'development'
  require 'pry'
  # db = Mongo::Connection.new(db_config["host"],db_config["port"].to_i).db(db_config["database"])
elsif ENVIRONMENT == 'production'
  # hosts = db_config["hosts"]
  # db = Mongo::ReplSetConnection.new(hosts.pop, hosts.pop, hosts.pop, read: :secondary, refresh_mode: :sync).db(db_config["database"])
end

# db.authenticate(db_config["username"],db_config["password"])
# redis = Redis.new(host: config['redis']['chat']['host'], port: config['redis']['chat']['port'].to_i)

FAYE_TOKEN = config['faye']['token']
 
class ServerAuth
  
  def incoming(message, callback)
    
    if message['channel'] !~ %r{^/meta/}
      if message['channel'] !~ %r{^/cloud/(.*)/presence}
        message['error'] = 'Invalid authentication token' if message['ext']['auth_token'] != FAYE_TOKEN
      end
    end

    callback.call(message)
    
  end
  
end

module Faye
  class WebSocket
    module API
      def close(code = nil, reason = nil, ack = true)
        return if [CLOSING, CLOSED].include?(ready_state)
        
        @ready_state = CLOSING
        
        close = lambda do
          @ready_state = CLOSED
          @stream.close_connection_after_writing unless @stream.nil?
          event = Event.new('close', :code => code || 1000, :reason => reason || '')
          event.init_event('close', false, false)
          dispatch_event(event)
        end
        
        if ack
          if @parser.respond_to?(:close)
            @parser.close(code, reason, &close)
          else
            close.call
          end
        else
          @parser.close(code, reason) if @parser.respond_to?(:close)
          close.call
        end
      end
    end
  end
end


server = Faye::RackAdapter.new(mount: '/faye',timeout: 25)
server.add_extension(ServerAuth.new)

EM.run do
  thin = Rack::Handler.get('thin')
  thin.run(server, :Port => config['faye']['port'].to_i)
end