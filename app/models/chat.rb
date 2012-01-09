class Chat
  
  include Mongoid::Document
  
  embedded_in :topic, polymorphic: true
  embeds_many :messages
  
  field :token,     type: String
  
end