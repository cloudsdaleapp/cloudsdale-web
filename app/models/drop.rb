class Drop
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable
  
  mount_uploader :preview, PreviewUploader
  
  voteable self, :up => +1, :down => -1
  
  embeds_many :deposits
  embeds_many :visits
  
  field :url,                 type: String
  field :match_id,            type: String
  field :status,              type: Array
  field :strategy,            type: Symbol
  
  field :title,               type: String
  
  field :metadata,            type: Hash
  field :last_load,           type: DateTime
  
  field :total_visits,        type: Integer,      default: 0
    
  validates :url, presence: true, format: /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i
  validates :match_id, presence: true
  validates :title, presence: true
  
  scope :expired, -> { where( :last_load.gt => 1.week.ago ) }
  
  before_save do
    reload if last_load.nil? or last_load < 1.week.ago
    self[:metadata] = {}.deep_merge(self[:metadata].to_hash)
  end
  
  def self.find_or_initialize_from_matched_url(url)
    response  = Urifetch.fetch_from(url)
    match_id  = response.data.match_id || response.strategy.uri.to_s
    
    if response.status[0].to_s == "200"
      drop = Drop.find_or_initialize_by(match_id: match_id)
      drop.set_data(response)
      drop
    else
      nil
    end
    

  end
  
  def visitable?
    status[0].to_s == "200"
  end
  
  def reload
    set_data Urifetch.fetch_from(url)
    has_been_loaded = true
  end
  
  def reload!
    reload
    save
  end
  
  def set_data(response)
    self[:title]      = response.data.title
    self[:metadata]   = {}.deep_merge(response.data.to_hash)
    self[:status]     = response.status
    self[:strategy]   = response.strategy.layout_key
    self[:last_load]  = -> { DateTime.current }.call
    self[:url]        = response.strategy.uri.to_s || self[:match_id]
    
    set_preview_image(self[:metadata]['preview_image'],self[:metadata]['preview_image_is_local']) if self[:metadata]['preview_image']
  end
  
  private
  
  def update_statistics
    self[:total_visits] = visit_ids.count
  end
  
  def set_preview_image(file,local=false)
    unless file.nil? and local.nil?
      if (local == false) or local.nil?
        # Triggers if file is Remote
        self.remote_preview_url = file
      elsif (local == true)
        # Triggers if file is a File or Tempfile
        self.preview = open(file)
      end
    end
  end

end
