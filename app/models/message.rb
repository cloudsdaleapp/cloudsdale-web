require 'rabl/renderer'

class Message
  
  include AMQPConnector
  
  include Mongoid::Document
  
  attr_accessor :client_id
  
  embedded_in :chat
  belongs_to :author, class_name: "User"
  
  field :timestamp,   type: Time,    default: -> { Time.now }
  field :content,     type: String
  
  # Meta attributes
  field :urls,        type: Array,    default: []
  
  validates :timestamp,   :presence => true
  validates :content,     :presence => true
  validates :author,      :presence => true
  
  before_validation do
    set_foreign_attributes! if author
  end
  
  after_save do
    enqueue! "faye", { channel: "/#{self.topic_type}s/#{self.topic_id}/chat/messages", data: self.to_hash } 
  end
  
  # Public: Translates the Message object to a HASH string using RABL
  #
  # Examples
  # 
  # @message.to_hash
  # # => { content: "..." }
  #
  # Returns a Hash string.
  def to_hash
    Rabl.render(self, 'api/v1/messages/mini', :view_path => 'app/views', :format => 'hash')
  end
  
  def topic_type
    chat.topic._type.downcase
  end
  
  def topic_id
    chat.topic._id.to_s
  end
  
  def utc_timestamp
    self[:timestamp].utc
  end
  
  def content=(msg)
    if (m = msg.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\!\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i do
        
        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path
        
        self[:urls] ||= []
        self[:urls] << url
        
        url
      end
    end
    
    self[:content] = msg
  end
  
  private
  
  def set_foreign_attributes!
    self[:user_name] = self.author.name
    self[:user_path] = "/users/#{author._id.to_s}"
    self[:user_avatar] = author.avatar.thumb.url
  end
  
end