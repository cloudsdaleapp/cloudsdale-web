class Pony < ActiveRecord::Base
  
  KINDS = [:pegasus,:unicorn,:earth]
  GROUPS = [:mare,:stallion,:filly,:colt]
  
  belongs_to :user
  
  validates :name, :uniqueness => true, :presence => true
  validates_format_of :name, :with => /^([A-Z][a-z]*\s?){1,3}$/, :message => "is invalid, use a-z, max three and capitalized words"
  validates_length_of :name, :within => 4..20, :message => "must be between 4 and 20 characters"
  
  validates_format_of :color_coat, :with => /^#[abcdef0-9]{6}$/i
  validates_format_of :color_mane, :with => /^#[abcdef0-9]{6}$/i
  validates_format_of :color_eyes, :with => /^#[abcdef0-9]{6}$/i
  
  def groups
    GROUPS
  end
  
  def kinds
    KINDS
  end
  
  def group=(o)
    self[:group] = o if groups.include?(o.to_sym)
  end
  
  def kind=(o)
    self[:kind] = o if kinds.include?(o.to_sym)
  end
  
end
