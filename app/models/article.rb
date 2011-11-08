class Article < Entry
  field :content,         type: String
  validates :content,     presence: true
end