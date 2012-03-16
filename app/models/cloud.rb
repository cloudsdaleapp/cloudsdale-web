class Cloud
  
  include Mongoid::Document
  include Mongoid::Timestamps

  include Droppable
  
  embeds_one :chat, as: :topic
  
  attr_accessor :user_invite_tokens
  
  field :name,          type: String
  field :description,   type: String
  field :hidden,        type: Boolean,        default: false
  field :locked,        type: Boolean,        default: false
  field :featured,      type: Boolean,        default: false
  field :member_count,  type: Integer,        default: 0
    
  mount_uploader :avatar, AvatarUploader

  validates :name, presence: true, uniqueness: true, length: { within: 3..24 }
  validates :description, presence: true, length: { within: 5..50 }
  
  has_one :drop, as: :local_reference, dependent: :delete, autosave: true
  belongs_to :owner, polymorphic: true
  
  has_and_belongs_to_many :users, :inverse_of => :clouds, dependent: :nullify
  
  before_validation do
    self.owner = self.users.first if owner.nil? and !users.empty?
    self[:name] = self[:name].slice(0..23) if name
    self[:user_ids].uniq!
  end
  
  before_save do
    self[:member_count] = self.user_ids.count
    self[:_type] = "Cloud"
    build_chat if chat.nil?
    
    if drop.nil?
      self.build_drop
    end
    
    self.drop.url       = "#{Cloudsdale.config['url']}/clouds/#{self._id.to_s}"
    self.drop.match_id  = self.drop.url
    self.drop.title     = self.name
    self.drop.status    = ["200","OK"]
    self.drop.strategy  = :cloudsdale_clouds
    self.drop.hidden    = self.hidden.to_s
    self.drop.last_load = Time.now
  
    self.drop.src_meta ||= {}
  
    self.drop.src_meta['avatar']           = self.avatar.preview.url
    self.drop.src_meta['member_count']     = self.member_count
    self.drop.src_meta['created_at']       = Time.now
    self.drop.src_meta['reference_id']     = self._id.to_s
  end
  
  def to_indexed_json
    self.to_json(:only => [ :_id, :name, :description, :hidden, :member_count, :hidden], :methods => [:avatar_versions])
  end

  def avatar_versions
    { normal: avatar.url, mini: avatar.mini.url, thumb: avatar.thumb.url, preview: avatar.preview.url }
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_avatar!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_avatar
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_avatar = nil
    end
  end
  
end