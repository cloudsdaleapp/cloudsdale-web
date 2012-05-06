class Authentication
  
  include Mongoid::Document
  
  attr_accessible :provider, :uid
  
  embedded_in :user
  
  field :provider,      type: String
  field :uid,           type: String
  
end
