class ServerAuth
  
  attr_reader :db, :redis
  
  def initialize(db,redis)
    @db = db
    @redis = redis
    @users = db["users"]
  end
  
  def incoming(message, callback)
    
    if message['channel'] !~ %r{^/meta/}
      message['error'] = 'Invalid authentication token' if message['ext']['auth_token'] != FAYE_TOKEN
    elsif message['channel'] =~ %r{^/meta/subscribe}
      if message['subscription'] =~ %r{^/users/(.*)}
        
        # Matches the ids sent from the client to validate it's bladibalala
        message['error'] = 'Ids are not matching' unless $1 == message['ext']['user_id']
        
        # Sets user specific data for caching purposes
        redis.hmset "users.#{message['ext']['user_id']}", :name,message['ext']['user_name'], :avatar,message['ext']['user_avatar'], :path,message['ext']['user_path']
        
        # Make subscribed client belong to user by id
        redis.set("fayeclients.#{message['clientId']}.user_id", message['ext']['user_id'])
      end
    end
    
    callback.call(message)
    
  end
  
end
