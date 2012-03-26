module Cloudsdale
  class Faye
    def self.broadcast(channel, data)
      message = { channel: channel, data: data, ext: { auth_token: FAYE_TOKEN } }
      Net::HTTP.post_form(Cloudsdale.faye_path(:inhouse), message: message.to_json)
    end
  end
end