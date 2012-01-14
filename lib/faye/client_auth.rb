class ClientAuth
  def outgoing(message, callback)
    
    message['ext'] ||= {}
    
    if message['channel'] !~ %r{^/meta/}
      message['ext']['auth_token'] = FAYE_TOKEN
    end
    
    callback.call(message)
    
  end
end
