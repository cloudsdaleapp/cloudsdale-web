class ServerAuth
  
  attr_reader :db, :redis, :server, :client
  
  def initialize(db,redis,server)
    @db = db
    @redis = redis
    @users = db["users"]
    @server = server
    @client = server.get_client
  end
  
  def incoming(message, callback)
    # puts "#{message['channel']} - #{ -> { Time.now.strftime('%R') }.call }"
    
    if message['channel'] !~ %r{^/meta/}
      message['error'] = 'Invalid authentication token' if message['ext']['auth_token'] != FAYE_TOKEN
    end
    
    if message['channel'] =~ %r{^/meta/subscribe}
      ext = message['ext']
      if message['subscription'] =~ %r{^/cloud/(.*)/presence}
        channels = server.instance_variable_get(:@server).engine.instance_variable_get(:@channels)
        sets = channels[message['subscription']]
        users = []
        unless sets.nil? or sets.empty?
          sets.to_a.each do |client_id|
            user = redis.hgetall("clients.#{client_id}.user") || nil
            users << user unless user.nil?
          end
        end
        users << { user_id: message['ext']['user_id'], user_name: message['ext']['user_name'], user_avatar: message['ext']['user_avatar'], user_path: message['ext']['user_path'] }
        EM.defer do
          client.publish message['subscription'], { status: 'join', users: users }
        end
      end
    end

    callback.call(message)
    
  end
  
  def outgoing(message,callback)
    
    if message['channel'] =~ %r{^/meta/handshake} and message["ext"]["server"] != true
      # Make subscribed client belong to user by id
      redis_key = "clients.#{message['clientId']}.user"
      EM.defer do
        redis.hset(redis_key, :user_id,     message['ext']['user_id'])
        redis.hset(redis_key, :user_name,   message['ext']['user_name'])
        redis.hset(redis_key, :user_avatar, message['ext']['user_avatar'])
        redis.hset(redis_key, :user_path,   message['ext']['user_path'])
      end
    end
    
    if message['channel'] =~ %r{^/meta/disconnect}
      redis.del("clients.#{message['clientId']}.user")
    end
    
    callback.call(message)
  end

  
end
