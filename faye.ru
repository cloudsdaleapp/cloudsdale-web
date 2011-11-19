require 'faye'
require 'yaml'

config = YAML.load_file("#{File.dirname(__FILE__)}/config/config.yml")[ENV['RACK_ENV']]

FAYE_TOKEN = config['faye']['token']

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      message['error'] = 'Invalid authentication token' if message['ext']['auth_token'] != FAYE_TOKEN
    end
    callback.call(message)
  end
end

faye = Faye::RackAdapter.new(mount: '/faye',timeout: 25)
    
faye.add_extension(ServerAuth.new)  
faye.listen(config['faye']['port'].to_i)