class Deposit
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :dropable, polymorphic: true
  belongs_to :drop
  
  validates_presence_of :drop_id

end