require 'faye'
require 'yaml'

faye = Faye::RackAdapter.new :mount => '/faye', :timeout => 25
faye.listen(9191)