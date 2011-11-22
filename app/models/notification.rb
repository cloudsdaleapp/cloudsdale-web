class Notification
  
  include Mongoid::Document
  
  embedded_in :user
  
  field :timestamp, type: Time
  field :actor,     type: String
  field :category,  type: String
  field :text,      type: String
  field :url,       type: String
  field :image,     type: String
  field :read,      type: Boolean,  default: false

  validates :actor,     :presence => true
  validates :category,  :presence => true
  validates :text,      :presence => true
  validates :url,       :presence => true
  
  default_scope order_by(:timestamp,:desc)
  scope :unread, where(read: false)
  

  before_validation :on => :create do
    self[:timestamp] = Time.now unless self.timestamp.present?
  end
  
  def mark_as_read!
    self.read = true
    save
  end

end