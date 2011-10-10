class Character
  
  KINDS = [:pegasus,:unicorn,:pony,:draconequus,:dragon,:gryphon]
  GENDERS = [:male,:female]
  
  include Mongoid::Document
  
  embedded_in :user
  
  field :name,    type: String
  field :kind,    type: String
  field :gender,  type: String
  field :age,     type: Integer
  
  validates :name, uniqueness: true, presence: true
  validates_format_of :name, with: /^([a-z]*\s?){1,3}$/i, message: "must use a-z and max three words"
  validates_length_of :name, within: 4..20, message: "must be between 4 and 20 characters"
  
  before_validation do
    self[:name] = self.name.split(/\s/).each{|w|w.capitalize!}.join(" ") if self.name
  end
  
  def gender=(o)
    self[:group] = o if GENDERS.include?(o.to_sym)
  end
  
  def kind=(o)
    self[:kind] = o if KINDS.include?(o.to_sym)
  end
  
end