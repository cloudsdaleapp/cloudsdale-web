module AMQPConnector

  def enqueue!(queue,data,tries=3)

    encoded_data = data.kind_of?(String) ? data : Yajl::Encoder.encode(data)

    exchange = Bunny::Exchange.new Cloudsdale.bunny_channel, :direct, "cloudsdale.push",
      auto_delete: false

    exchange.publish(encoded_data, key: "#", content_type: "application/json")

  rescue Bunny::ServerDownError
    enqueue! queue, data, (tries - 1) if tries >= 1
  end

end
