class Reflection
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :drop
  belongs_to :author, :class_name => "User"
  
  field :content,       type: String
  
  validates :content, presence: true, length: { within: 1..120 }

  
end