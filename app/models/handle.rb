# encoding: utf-8

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

  index( { name: 1 }, { unique: true, name: 'name_index' } )
  index( { _id:  1 }, { unique: true, name: 'id_index' } )
  index( { _id:  1, identifiable_id: 1 }, { name: 'lookup_index' } )
  index( { _id:  1, identifiable_type: 1 }, { name: 'lookup_type_index' } )
  index( { identifiable_id:  1 }, { name: 'lookup_foreign_index' } )

  validates :_id,   presence: true,  uniqueness: true,  username: true

  after_save    :write_memory_cache
  after_destroy :clear_memory_cache

  # Public: Setter for the name attribute. Will also set the attribute _id.
  #
  # value - The handle name
  #
  # Returns the set value as a string.
  def name=(value)
    value      = self.class.sanitize_name(value)
    self[:_id] = value.upcase
    super(value)
  end

  def self.sanitize_name(value)
    value.strip.gsub(' ','').first(MAX_LENGTH)
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
  def self.lookup(value, kind: nil)
    id_value = value.to_s.upcase.gsub("-","_")

    handle ||=  find_in_cache(id_value)

    handle ||=  self.where(identifiable_id: value).limit(1).first if value.match(/^[0-9a-fA-F]{24}$/)
    handle ||=  self.where(_id: id_value).limit(1).first if kind.nil?
    handle ||=  self.where(_id: id_value, identifiable_type: kind.to_s).limit(1) if kind.present?

    if handle && handle.identifiable && (kind.nil? || handle.identifiable.class.to_s == kind.to_s)
      return handle.identifiable
    else
      raise Mongoid::Errors::DocumentNotFound.new(
        (kind || Handle::IdentifiableRecord),
        id_value,
        value.strip.gsub(' ','').first(MAX_LENGTH)
      )
    end
  end

  # Public: Tries to look up a record based upon an existing handle through it's
  # name or identifiable id.
  #
  # Returns an arbitrary record or nil if no record is found.
  def self.lookup!(value, kind: nil)
    return lookup(value, kind: kind)
  rescue Mongoid::Errors::DocumentNotFound
    return nil
  end

  # Public: Custom builder for handles based on identifiable records, uses attributes
  # on model to determine the handle ID and name values. Will try and find a pre-existing
  # handle before creating a new one.
  #
  # record - Any existing database record.
  #
  # Returns a handle. Always.
  def self.build(record, name)
    name = sanitize_name(name)

    handle ||= where(_id: name.upcase, :identifiable_id.in => [record.id, nil]).first
    handle ||= new(_id: name.upcase, name: name, identifiable: record)

    handle.identifiable = record
    handle.name         = name

    return handle
  end

  # Public: Derive a unique handle based on identifiable records.
  #
  # record - Any existing database record.
  #
  # Returns a Handle. Always.
  def self.build_unique(record, name)
    build(record, name).generate_unique_name
  end

  # Public: Generates a unique name on your handle automatically.
  #
  # Returns the handle.
  def generate_unique_name
    n = 0
    begin
      new_name  = nil
      iteration = n.to_s

      new_name  ||= name if n.zero?
      new_name  ||= (name + " ").truncate(MAX_LENGTH,
        omission: iteration,
        separator: ""
      ) if (name + iteration).length >= MAX_LENGTH
      new_name  ||= (name + iteration)

      n += 1
    end while self.class.where(_id: new_name.upcase, :identifiable_id.ne => identifiable.id.to_s).exists?

    self.name = new_name

    return self
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