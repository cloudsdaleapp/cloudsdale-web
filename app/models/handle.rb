class Handle

  class IdentifiableRecord
    extend ActiveModel::Naming
  end

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :identifiable,   polymorphic: true

  field :_id,     type: String,   default: -> { name? ? name : Moped::BSON::ObjectId.new }
  field :name,    type: String

  index({ name: 1 }, { unique: true })
  index({ _id:  1 }, { unique: true })
  index({ identifiable_id:   1 })
  index({ identifiable_type: 1 })
  index({ created_at: 1 })
  index({ updated_at: 1 })

  validates :name,  presence: true,  uniqueness: true,  username: true
  validates :_id,   presence: true,  uniqueness: true,  username: true

  # Public: Setter for the name attribute. Will also set the attribute _id.
  #
  # value - The handle name
  #
  # Returns the set value as a string.
  def name=(value)
    self[:_id] = value.upcase
    super(value)
  end

  # Public: Custom finder that upcase the value to adhere to database convention
  # of upper case handle ID's. This is for MongoDB make queries through indexes
  # independent of what value was provided.
  #
  # value - The handle name
  #
  # Returns a handle or raise an error if none is to be found.
  def self.find(value)
    super(value.upcase)
  end

  def self.find_record(value)
    handle = self.find_by(name: value).or(identifiable_id: value)
    if not handle.identifiable
      raise Mongoid::Errors::DocumentNotFound.new(Handle::IdentifiableRecord, handle._id, handle.name)
    else
      return handle.identifiable
    end
  end

  def self.generate_from(record)

  end

end