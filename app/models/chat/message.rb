class Chat::Message
  
  include Mongoid::Document
  
  field :sender, type: String
  field :timestamp, type: Time
  field :content, type: String
  
end