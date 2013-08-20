class Handle

  MAX_LENGTH = 20

  class IdentifiableRecord
    extend ActiveModel::Naming
  end

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :identifiable,   polymorphic: true,   touch: true

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

  after_save    :write_memory_cache
  after_destroy :clear_memory_cache

  # Public: Setter for the name attribute. Will also set the attribute _id.
  #
  # value - The handle name
  #
  # Returns the set value as a string.
  def name=(value)
    value      = value.strip.gsub(' ','').first(MAX_LENGTH)
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
    find_in_cache(value.upcase) || super(value.upcase)
  end

  # Public: Checks if record exists with a handle with a specific name exists.
  #
  # value - The handle name
  #
  # Returns true or false.
  def self.find?(value)
    find_in_cache?(value) || where(_id: value.upcase).exists?
  end

  # Public: Tries to find the record in the memory cache.
  #
  # value - The handle name
  #
  # Returns a Handle if one is found.
  def self.find_in_cache(value)
  if marshal = $redis.get(memory_cache_key + ":#{value.upcase}")
    return marshal_load(marshal)
  end
  rescue
    return nil
  end

  # Public: Checks if record exists in cache
  #
  # value - The handle name
  #
  # Returns true or false.
  def self.find_in_cache?(value)
    $redis.exists(memory_cache_key + ":#{value.upcase}")
  end

  # Public: Tries to look up a record based upon an existing handle through it's
  # name or identifiable id.
  #
  # Returns an arbitrary record or raise an error if no record is found.
  def self.lookup(value)
    handle = find_in_cache(value.upcase) || self.where(_id: value.upcase).or(identifiable_id: value).first
    if handle && handle.identifiable
      return handle.identifiable
    else
      raise Mongoid::Errors::DocumentNotFound.new(Handle::IdentifiableRecord, handle._id, handle.name)
    end
  end

  # Public: Custom builder for handles based on identifiable records, uses attributes
  # on model to determine the handle ID and name values. Will try and find a pre-existing
  # handle before creating a new one.
  #
  # record - Any existing database record.
  #
  # Returns a handle. Always.
  def self.derive_from(record)
    name ||= record.handle      if record.respond_to?(:handle)
    name ||= record.username    if record.respond_to?(:username)
    name ||= record.short_name  if record.respond_to?(:short_name)
    name ||= record.name        if record.respond_to?(:name)
    name ||= record.id

    self.find_or_initialize_by(identifiable: record, name: name)
  end

  # Public: Derive a unique handle based on identifiable records.
  #
  # record - Any existing database record.
  #
  # Returns a Handle. Always.
  def self.derive_unique_from(record)
    handle = derive_from(record)
    found  = 0

    begin
      new_name  = nil
      iteration = found.to_s

      new_name  ||= handle.name if found.zero?
      new_name  ||= (handle.name + " ").truncate(MAX_LENGTH,
        omission: iteration,
        separator: ""
      ) if (handle.name + iteration).length >= MAX_LENGTH
      new_name  ||= (handle.name + iteration)

      found    += 1
    end while find?(new_name)

    handle.name = new_name

    return handle
  end

private

  # Private: Constructs a cache key for the record type.
  # Returns a String.
  def self.memory_cache_key
    "#{$redis_ns}:handles"
  end

  # Private: Loads a marshal string and instantiates and recrod from it.
  # Returns a Handle.
  def self.marshal_load(string, *args, &block)
    raw_attributes = Marshal.load(string, *args, &block)
    instantiate(raw_attributes)
  end

  # Private: Constructs a memory cache key for the specific record.
  # Returns a String.
  def memory_cache_key
    "#{self.class.memory_cache_key}:#{self.id}"
  end

  # Private: Writes the object to the memory cache.
  # Returns true.
  def write_memory_cache
    $redis.set(memory_cache_key,marshal_dump) && true
  end

  # Private: Clears the record from the memory cache.
  # Returns true.
  def clear_memory_cache
    $redis.del(memory_cache_key) && true
  end

  # Private: Dumps record as a marshal string.
  # Returns a String.
  def marshal_dump(*args, &block)
    Marshal.dump(raw_attributes, *args, &block)
  end

end