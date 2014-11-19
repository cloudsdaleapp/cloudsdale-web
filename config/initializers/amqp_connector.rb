module AMQPConnector

  def enqueue!(queue,data,tries=3)

    encoded_data = data.class == String ? data : Yajl::Encoder.encode(data)

    q = Cloudsdale.bunny.queue(queue)
    e = Cloudsdale.bunny.exchange('')

    e.publish(encoded_data, :key => queue.to_s, :content_type => "application/json")
  rescue Bunny::ServerDownError
    enqueue!(queue,data,(tries - 1)) if tries >= 1
  end

end
