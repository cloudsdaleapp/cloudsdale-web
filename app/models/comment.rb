class Comment
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :topic, polymorphic: true
  belongs_to :author, :class_name => "User"
  
  field :content
  
  validates :content, presence: true, length: { within: 1..300 }
  
  default_scope order_by(:created_at => :desc)
  
end