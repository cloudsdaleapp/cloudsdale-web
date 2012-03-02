class Reflection
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable
  
  voteable self, :up => +1, :down => -1
  
  embedded_in :drop
  belongs_to :author, :class_name => "User"
  
  field :content
  
  validates :content, presence: true, length: { within: 1..120 }
  
  #default_scope order_by(:'votes.point' => :desc, :created_at => :desc)
  
end