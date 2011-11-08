class Tag
  
  include Mongoid::Document
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  has_and_belongs_to_many :entries, :inverse_of => :tags, dependent: :nullify
  
  attr_accessible :name
  
  field :name,            type: String
  field :times_referred,  type: Integer,    default: 0
  
  validates :name, presence: true, uniqueness: true, format: { with: /^[a-z\s]*$/i }, length: { within: 2..16 }
  
  default_scope order_by(:times_referred,:desc)
  
  mapping do
    indexes :name,      :type => 'string',      :index => :not_analyzed
  end
  
  before_save do
    set_times_referred!
    format_name!
  end
  
  def token_inputs
    { :id => _id, :name => name, :times_referred => times_referred }
  end

  # Tire, Mongoid requirements
  index_name 'mongo-tags'
  
  def to_indexed_json
    self.to_json
  end
  
  def set_times_referred!
    self[:times_referred] = self.entry_ids.count
  end
  
  def format_name!
    self[:name] = self.name.gsub(/\-\\\_\<\>/i,"").downcase
  end
  
end