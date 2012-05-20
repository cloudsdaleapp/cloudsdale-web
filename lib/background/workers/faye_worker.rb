# encoding: utf-8

require 'helpers/faye'

# Public: A worker that processes chat messages
# and broadcast them to a given destination.
class FayeWorker
  
  include Worker::Base # Scripts, Daemons & Redis
  include Worker::REnv # Rails Environment
  include Worker::Queue # Queue Connector
  
  include Worker::Helper::Faye # Faye Broadcaster
  
  queue :faye # The AMQP queue from which messages should be pop'd when available
  
  # Public: The action performed as soon as there's a new message in the queue
  # 
  # payload - The Hashr options should contain (default: Hashr.new):
  #           :channel - The channel to which the data should be broadcasted.
  #           :data - The data which will be broadcasted.
  # 
  # Requests faye to broadcast the message to the given channel.
  def perform(payload=Hashr.new)
    
    log.debug("Message Payload: #{payload}")
    broadcast payload.channel, payload.data
    
  end

end