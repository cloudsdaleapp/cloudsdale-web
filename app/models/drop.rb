class Drop
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable
  
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
  end
  
  def self.find_or_initialize_from_matched_url(url)
    response  = Urifetch.fetch_from(url)
    match_id  = response.data.match_id || response.strategy.match_data.to_s
    
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
    self[:metadata]   = {}.merge(response.data)
    self[:status]     = response.status
    self[:strategy]   = response.strategy.layout_key
    self[:last_load]  = -> { DateTime.current }.call
    self[:url]        = response.strategy.match_data.to_s || self[:match_id]
  end
  
  private
  
  def update_statistics
    self[:total_visits] = visit_ids.count
  end

end
