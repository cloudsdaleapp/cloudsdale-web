require 'faye'
require 'yaml'

config = YAML.load_file("./config/config.yml")['development']

faye = Faye::RackAdapter.new(
          :mount => '/faye',
          :timeout => 25
      )
      
faye.listen(9191)