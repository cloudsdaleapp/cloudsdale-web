# encoding: utf-8

module Worker

  module Helper
    
    # Public: Including this in a class will give you access to making
    # asynchrounous requests to the Faye server.
    module Faye
    
      # Public: Broadcast data to a given channel through Faye
      #
      # Examples
      #
      # channel - The faye channel of which
      # data - A hash of data to be sent to the clients
      # callback - Proc or Lambda to perform when the request is successful
      # errback - Proc or Lambda to perform when the request is unsuccessful
      # broadcast "some/channel/name", { hello: data.world }, -> { puts "sent" }, , -> { puts "something went wrong" }
      #
      # Returns nothing.
      def broadcast(channel, data, callback=Proc.new{}, errback=Proc.new{})
        
        message = { channel: channel, data: data, ext: { auth_token: FAYE_TOKEN } }
        
        http = EventMachine::HttpRequest.new(Cloudsdale.faye_path(:inhouse)).apost(
          query: { message: Yajl::Encoder.encode(message) }
        )
          
        http.callback do
          log.info("Broadcasted message through faye on channel #{channel}.")
          callback.call
        end
        
        http.errback do
          log.warn("Was unable to broadcast message through faye on channel #{channel}.")
          errback.call
        end
        
      end
    
    end
    
  end
  
end