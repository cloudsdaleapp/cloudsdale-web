class Article < Entry
  field :content,         type: String
  field :preambel,        type: String
  
  validates :content,     presence: true
  validates :preambel,    presence: true
end