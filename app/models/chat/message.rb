class Chat::Message
  
  include Mongoid::Document
  
  field :sender, type: String
  field :timestamp, type: Time
  field :content, type: String
  
  validates :timestamp, :presence => true
  validates :sender, :presence => true
  validates :content, :presence => true
  
  def content=(msg)
    msg.gsub! /<\/?[^>]*>/, ""
    msg.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "<br/>"
    msg.gsub! /<br\/><br\/>/,"<br/>"
    msg.gsub! /^\s*$/, ""
    msg.gsub! /\"/, '\\"'
    
    if (m = msg.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_]*)(\/?[a-z0-9\.\,\-\_\/\?\&\=\#]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path
        "<a class='chat-link' href='#{url}' target='_blank'>#{url}</a>"
      end
    end
    
    self[:content] = msg
  end
  
  before_validation do
    self[:timestamp] = Time.now
  end
  
end