class Chat::Room
  
  include Mongoid::Document
  
  embedded_in :topic, polymorphic: true
  embeds_many :messages, class_name: "Chat::Message"
  
  field :token,     type: String
  
  before_save do
    generate_access_token!
  end
  

private
  
  def generate_access_token!
    self[:token] = SecureRandom.hex(24) if self.token.nil?
  end
  
end