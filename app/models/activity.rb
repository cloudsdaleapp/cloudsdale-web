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
  
  after_save do
    notify_subscribers! if [:article].include?(category.to_sym)
  end
  
  def notify_subscribers!
    user.subscribers.each do |subscriber|
      subscriber.notifications.create timestamp: timestamp, actor: user.name, category: category, text: text, url: url, image: user.avatar.mini.url
    end
  end
  
end