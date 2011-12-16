class Article < Entry
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  field :content,         type: String
  field :preambel,        type: String
  
  validates :content,     presence: true
  validates :preambel,    presence: true
  
  # Tire, Mongoid requirements
  index_name 'articles'
  
  tire.settings AutocompleteAnalyzer do
    mapping {
      indexes :_id,            type: 'string',       index: :not_analyzed
      indexes :_type,          type: 'string',       index: :not_analyzed
  
      indexes :title,          type: 'multi_field',  fields: {
        title: {
          type: 'string',
          boost: 100,
          analyzer: 'autocomplete'
        },
        "title.exact" => { 
          type: 'string', 
          index: :not_analyzed
        }
      }
      indexes :preambel,          type: 'multi_field',  fields: {
        preambel: {
          type: 'string',
          boost: 30,
          analyzer: 'autocomplete'
        },
        "preambel.exact" => { 
          type: 'string', 
          index: :not_analyzed
        }
      }
      indexes :_all,          analyzer: 'autocomplete'
    }
  end
  
  def to_indexed_json
    self.to_json(:only => [ :_id, :_type, :hidden, :title, :preambel ], :methods => [:name,:description])
  end
  
  def name
    self.title
  end
  
  def description
    self.preambel
  end
  
end