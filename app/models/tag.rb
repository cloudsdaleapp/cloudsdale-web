class Tag
  
  include Mongoid::Document
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  has_and_belongs_to_many :entries, :inverse_of => :tags, dependent: :nullify
  
  attr_accessible :name
  
  field :name,            type: String
  
  validates :name, presence: true, uniqueness: true, format: { with: /^[a-z\s\d]*$/i }, length: { within: 2..16 }
  
  before_save do
    set_times_referred!
    format_name!
  end
  
  mapping do
    indexes :id,            type: 'string',       index: :not_analyzed
    indexes :type,          type: 'string',       index: :not_analyzed
    indexes :name,          type: 'string',       index: :not_analyzed,     boost: 100
  end

  # Tire, Mongoid requirements
  index_name 'tags'
  
  def to_indexed_json
    self.to_json(:only => [ :_id, :name ], :methods => [:times_referred])
  end
  
  def times_referred
    self.entry_ids.count
  end
  
  def format_name!
    self[:name] = self.name.gsub(/\-\\\_\<\>/i,"").downcase
  end
  
end