module AMQPConnector
  
  def enqueue!(queue,data=self.to_queue)
    q = Cloudsdale.bunny.queue(queue)
    e = Cloudsdale.bunny.exchange('')
    e.publish(data,:key => queue)
  end
  
  def to_queue
    self.to_json
  end

end