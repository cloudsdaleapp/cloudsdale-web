class Prosecution
  
  SENTENCES = { :mute => 0, :kick => 1, :ban => 2 }
  JUDGEMENTS = { :guilty => 0, :not_guilty => 1 }
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Mongo::Voteable
  
  voteable self, :up => 1, :down => -1
  
  attr_accessor :get_verdict
  
  attr_accessible :get_verdict, as: [:prosecutor]
  attr_accessible :argument, :sentence, :sentence_due
  
  embedded_in :offender
  
  belongs_to :prosecutor,   :class_name => "User"
  belongs_to :crime_scene,  polymorphic: true
  
  field :argument,      type: String
  
  field :judgement,     type: Symbol
  
  field :sentence,      type: Symbol
  field :sentence_due,  type: DateTime
  
  validate :argument, length: { within: 1..140 }
  
  validate :sentence, format: { in: SENTENCES.keys }
  validate :sentence_due
  
  validate :judgement, format: { in: JUDGEMENTS.keys }
  
  validates_presence_of [:argument, :sentence, :sentence_due]
  
  before_update :calculate_judgement
  
  # Public: Calculates and sets what judgement is to be.
  # if the up votes exceeds the down votes the judgement
  # is set to :guilty, otherwise :not_guilty .
  #
  # Returns the judgement Symbol.
  def calculate_judgement
    
    if self.judgement.nil? && self.get_verdict
      self.judgement = self.votes["up_count"] > self.votes["down_count"] ? :guilty : :not_guilty
    end
    
    self.judgement
    
  end
  
end