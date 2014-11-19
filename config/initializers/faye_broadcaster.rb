module Cloudsdale
  class Faye
    def self.broadcast(channel, data)
      message = { channel: channel, data: data, ext: { auth_token: Figaro.env.faye_token! } }
      Net::HTTP.post_form(Figaro.env.faye_https_url!, message: message.to_json)
    end
  end
end