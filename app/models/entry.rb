class Entry
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :tags, :inverse_of => :entries, dependent: :nullify
  
  belongs_to :author, polymorphic: true
  embeds_many :comments, as: :topic
  
  attr_reader :tag_tokens

  def tag_tokens=(tag_names)
    self.tags.clear
    tag_names = tag_names.split(',')
    collected_tags = Tag.any_in(name: tag_names).to_a
    tag_names -= collected_tags.map(&:name)
    tag_names.each do |tag_name|
      collected_tags << Tag.create({name:tag_name})
    end
    self.tags = collected_tags
  end
  
  field :title,         type: String
  field :preambel,      type: String
  
  field :views,         type: Integer,    default: 0
  
  field :published,     type: Boolean,    default: true
  field :commentable,   type: Boolean,    default: true
  field :hidden,        type: Boolean,    default: false
  field :promoted,      type: Boolean,    default: false
  
  mount_uploader :banner, BannerUploader
  
  validates :title,       presence: true,   uniqueness: true,   length: { within: 5..46 }
  validates :preambel,    presence: true
  
  def log_view_count_and_save!
    self[:views] += 1
    save!
  end
  
  def promote_and_save!
    Article.where(promoted: true).update_all(promoted: false)
    self[:promoted] = true
    self[:published] = true
    self[:hidden] = false
    self[:commentable] = true
    save!
  end
  
  def publish_and_save!
    self[:published] = true
    save!
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_banner!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_banner
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_banner = nil
    end
  end
  
end