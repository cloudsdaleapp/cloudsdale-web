class Visit
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :drop
  
  belongs_to :user
  
end