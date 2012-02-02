class Drop
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  
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
  field :hidden,              type: String,       default: "false"
  
  field :total_visits,        type: Integer,      default: 0
    
  validates :url, presence: true, format: /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i
  validates :match_id, presence: true
  validates :title, presence: true
  
  scope :expired, -> { where( :last_load.gt => 1.week.ago ) }
  
  before_save do
    reload if last_load.nil? or last_load < 1.week.ago
    self[:metadata] = {}.deep_merge(self[:metadata].to_hash)
  end
  
  # Tire, Mongoid requirements
  index_name 'mongo-drops'
  
  tire.settings  :number_of_shards => 1,
            :analysis => {
               :analyzer => {
                 :drop_analyzer => {
                   "type"         => "custom",
                   "tokenizer"    => "standard",
                   "filter"       => ["stop","lowercase","drop_ngram"]
                 }
               },
               :filter => {
                 :drop_ngram  => {
                   "type"     => "nGram",
                   "min_gram" => 1,
                   "max_gram" => 20 }
                }
  } do mapping {             
      indexes :id,            :type => 'string',       :index => :not_analyzed
      indexes :type,          :type => 'string',       :index => :not_analyzed
      indexes :title,         :type => 'string',       :index_analyzer => 'drop_analyzer', :search_analyzer => 'standard',     :boost => 10
      indexes :hidden,        :type => 'string'
    }
  end
  
  def to_indexed_json
    self.to_json(:only => [ :_id,:_type,:title,:total_visits,:strategy,:metadata,:votes,:created_at,:updated_at,:hidden], :methods => [:preview_versions])
  end
  
  def self.paginate(options = {})
     page(options[:page]).per(options[:per_page])
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
    self[:url]        = self[:match_id] || response.strategy.uri.to_s
    
    set_preview_image(self[:metadata]['preview_image'],self[:metadata]['preview_image_is_local']) if self[:metadata]['preview_image']
  end
  
  private
  
  def hidden_as_string
    val = self[:hidden] || "false"
    { hidden: val.to_s }
  end
  
  def preview_versions
    { default: self.preview.url }
  end
  
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
