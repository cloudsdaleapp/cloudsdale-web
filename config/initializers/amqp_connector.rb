module AMQPConnector

  def enqueue!(queue,data,tries=3)

    encoded_data = data.class == String ? data : Yajl::Encoder.encode(data)
    e = Cloudsdale.bunny.exchange('')
    e.publish(encoded_data, :key => queue, :content_type => "application/json")
  rescue Bunny::ServerDownError
    enqueue!(queue,data,(tries - 1)) if tries >= 1
  end

end
