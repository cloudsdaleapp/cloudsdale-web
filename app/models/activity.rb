class Activity
  
  include Mongoid::Document
  
  embedded_in :user
  
  field :timestamp, type: Time
  field :category,  type: String
  field :text,      type: String
  field :url,       type: String
  
  validates :category,  :presence => true
  validates :text,      :presence => true
  validates :url,       :presence => true
  
  before_validation :on => :create do
    self[:timestamp] = Time.now unless self.timestamp.present?
  end
  
end