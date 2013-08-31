# encoding: utf-8

class Spotlight

  CATEGORIES = [
    :roleplay,
    :podcast,
    :casual,
    :livestream,
    :education
  ]

  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :handle

  field :text,     type: String
  field :category, type: String

  index({ created_at: 1 })
  index({ category: 1, created_at: -1 })

  belongs_to :target,  polymorphic: true,  :validate => false

  validates :target,   presence: true
  validates :text,     presence: true, length: {
    within: 1..108
  }
  validates :category, presence: true, inclusion: {
    :in => CATEGORIES.map(&:to_s)
  }

  after_initialize do
    self[:_type] = "Spotlight"
  end

  # Public: Method to build a new Spotlight using
  # strong parameters through arcane.
  #
  # Returns a spotlight.
  def self.refined_build(params)
    spotlight = self.new
    spotlight.write_attributes(params.for(spotlight).refine)
    return spotlight
  end

  # Public: Customer setter for handle to do a lookup
  # on identifiable records.
  #
  # Returns a record or nil.
  def handle=(value)
    self.target = Handle.lookup(value)
  rescue
    return nil
  end

end