class Deposit
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :drop
  belongs_to :depositable, polymorphic: true
  has_and_belongs_to_many :depositers, class_name: "User"
  
  before_save do
    self["#{depositable_id.to_s}_updated_at".to_sym] = !self.updated_at.nil? ? self.updated_at.utc : Time.now.utc
    self["#{depositable_id.to_s}_created_at".to_sym] = !self.created_at.nil? ? self.created_at.utc : Time.now.utc
    self[:depositable_type] = self[:depositable_type].classify
    self[:depositer_ids].uniq!
  end

end