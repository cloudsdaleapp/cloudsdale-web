class Authentication
  
  include Mongoid::Document
  
  embedded_in :user
  
  field :provider,      type: String
  field :uid,           type: String
  
end
