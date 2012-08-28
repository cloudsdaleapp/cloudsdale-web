module AMQPConnector
  
  MAX_TRIES = 3
  
  def enqueue!(queue,data)
    
    encoded_data = data.class == String ? data : Yajl::Encoder.encode(data)
        
    q = Cloudsdale.bunny.queue(queue)
    e = Cloudsdale.bunny.exchange('')
    
    MAX_TRIES.times do |i|
      begin
        e.publish(encoded_data, :key => queue.to_s, :content_type => "application/json")
        break
      rescue Bunny::ServerDownError => e
        Cloudsdale.bunny.stop
        Cloudsdale.bunny.start
      end
    end
  end
  
end

Cloudsdale.bunny.queue 'faye'
Cloudsdale.bunny.queue 'drops'