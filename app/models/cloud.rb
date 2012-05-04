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
    
    build_chat unless chat.present?
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