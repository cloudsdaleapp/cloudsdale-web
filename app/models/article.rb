class Article
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :tags, :inverse_of => :articles, dependent: :nullify
  
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
  
  field :permalink,     type: String
  field :title,         type: String
  field :preambel,      type: String
  field :content,       type: String
  field :views,         type: Integer,    default: 0
  field :published,     type: Boolean,    default: false
  field :uncommentable, type: Boolean,    default: false
  field :hidden,        type: Boolean,    default: false
  field :is_promoted,   type: Boolean,    default: false
  
  mount_uploader :banner, BannerUploader
  
  validates :title,       presence: true,   uniqueness: true,   length: { within: 5..46 }
  validates :permalink,   presence: true,   uniqueness: true
  validates :preambel,    presence: true
  validates :content,     presence: true
  
  scope :promoted, where(is_promoted: true)
  
  def title=(str)
    self[:title] = str
    self[:permalink] = str.parameterize
  end
  
  def log_view_count_and_save!
    self[:views] += 1
    save!
  end
  
  def promote_and_save!
    Article.promoted.update_all(is_promoted: false)
    self[:is_promoted] = true
    self[:published] = true
    self[:hidden] = false
    self[:uncommentable] = false
    save!
  end
  
  def publish_and_save!
    self[:published] = true
    save!
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