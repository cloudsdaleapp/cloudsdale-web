class Drop
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable
  
  voteable self, :up => +1, :down => -1
  
  
  field :url,                 type: String
  field :match_id,            type: String
  field :status,              type: Array
  field :strategy,            type: Symbol
  
  field :title,               type: String
  
  field :metadata,            type: Hash
  field :last_load,           type: DateTime
    
  validates :url, presence: true, format: /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i
  validates :match_id, presence: true
  validates :title, presence: true
  
  scope :expired, -> { where( :last_load.gt => 1.week.ago ) }
  
  before_save do
    reload if last_load.nil? or last_load < 1.week.ago
  end
  
  def self.find_or_initialize_from_matched_url(url)
    response  = Urifetch.fetch_from(url)
    match_id  = response.data.match_id || response.strategy.match_data.to_s
    
    drop = Drop.find_or_initialize_by(match_id: match_id)
    drop.set_data(response)
    drop
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
    self[:title]      = response.data.title[0..62]
    self[:metadata]   = {}.merge(response.data)
    self[:status]     = response.status
    self[:strategy]   = response.strategy.layout_key
    self[:last_load]  = -> { DateTime.current }.call
    self[:url]        = response.strategy.match_data.to_s || match_id
  end
  
end
