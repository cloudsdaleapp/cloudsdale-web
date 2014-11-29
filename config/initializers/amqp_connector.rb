module AMQPConnector

  def enqueue!(queue,data,tries=3)

    encoded_data = data.kind_of?(String) ? data : Yajl::Encoder.encode(data)

    exchange = Bunny::Exchange.new bunny_channel, :direct, "cloudsdale.push",
      auto_delete: false

    exchange.publish(encoded_data, key: "#", content_type: "application/json")

  rescue Bunny::ServerDownError, Bunny::ConnectionClosedError
    enqueue! queue, data, (tries - 1) if tries >= 1
  rescue Bunny::UnexpectedFrame, Bunny::ChannelError, Bunny::TCPConnectionFailedForAllHosts
  end

  def bunny
    $bunny ||= Bunny.new(Figaro.env.amqp_url!, logger: Rails.logger)
    $bunny.start unless $bunny.connected?
    return $bunny
  end

  def bunny_channel
    $bunny_channel ||= bunny.create_channel
  end

end
