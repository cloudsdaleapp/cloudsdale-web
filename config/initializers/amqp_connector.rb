module AMQPConnector
  
  def enqueue!(queue,data)
    
    encoded_data = data.class == String ? data : Yajl::Encoder.encode(data)
        
    q = Cloudsdale.bunny.queue(queue)
    e = Cloudsdale.bunny.exchange('')
    e.publish(encoded_data, :key => queue.to_s)
    
  end
  
end