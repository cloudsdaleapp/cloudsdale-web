module ApplicationHelper
  
  def broadcast(channel, &block)
    message = {:channel => "/#{channel}", :data => capture(&block)}
    Net::HTTP.post_form(Cloudsdale.faye_path, :message => message.to_json)
  end
  
end
