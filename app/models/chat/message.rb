class Chat::Message
  
  include Mongoid::Document
  
  embedded_in :room, class_name: "Chat::Room"
  belongs_to :author, class_name: "User"
  
  field :timestamp,   type: Time,    default: -> { Time.now }
  field :content,     type: String
  
  # Meta attributes
  field :user_name,   type: String
  field :user_path,   type: String
  field :user_avatar, type: String
  
  validates :timestamp,   :presence => true
  validates :content,     :presence => true
  
  before_validation do
    set_foreign_attributes!
  end
  
  def content=(msg)
    msg.gsub! /<\/?[^>]*>/, ""
    msg.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "<br/>"
    msg.gsub! /<br\/><br\/>/,"<br/>"
    msg.gsub! /^\s*$/, ""
    
    if (m = msg.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        pjax_enabled = !(top_dom =~ /cloudsdale.org/i).nil?   
        url = protocol + top_dom + path
        "<a class='chat-link' href='#{url}' #{!pjax_enabled ? "target='_blank' data-skip-pjax='true'" : ''}>#{url}</a>"
      end
    end
    
    self[:content] = msg
  end
  
  def formatted_timestamp
    self.timestamp.strftime("%H:%M:%S")
  end
  
  def set_foreign_attributes!
    self[:user_name] = self.author.character.name
    self[:user_path] = "/users/#{self.author_id}"
    self[:user_avatar] = author.avatar.thumb.url
  end
  
end