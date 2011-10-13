class Character
  
  class UserGlobalUniquenessValidator < ActiveModel::EachValidator
  
    def validate_each(object,attribute,value)
      unless object.user.class.where("character.#{attribute}" => value).excludes("_id" => object.user.id).count == 0
        object.errors[:attribute] << "is already taken, sorry"
      end
    end
  
  end
  
  KINDS = [:pegasus,:unicorn,:pony,:draconequus,:dragon,:gryphon]
  GENDERS = [:male,:female]
  
  include Mongoid::Document
  
  embedded_in :user
  
  field :name,    type: String
  field :kind,    type: String
  field :gender,  type: String
  field :age,     type: Integer
  
  validates :name, presence: true, :user_global_uniqueness => { :message => "is not unique" }
  validates_format_of :name, with: /^([a-z]*\s?){1,5}$/i, message: "must use a-z and max five words"
  validates_length_of :name, within: 3..30, message: "must be between 3 and 30 characters"
  
  def name=(o)
    self[:name] = o.split(/\s/).each{|w|w.capitalize!}.join(" ") if o
  end
  
  def gender=(o)
    self[:gender] = o if GENDERS.include?(o.to_sym)
  end
  
  def kind=(o)
    self[:kind] = o if KINDS.include?(o.to_sym)
  end
  
end