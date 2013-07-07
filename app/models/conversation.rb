# encoding: utf-8
#
# Public: Conversations is a proxy object for objects where
# you should be able to access chat. The conversation is
# embedded within the record of the conversee rather than
# the topic of conversation itself.
class Conversation

  TOPIC_TYPES  = ["Cloud", "User"]
  STATUS_TYPES = [:offline, :online, :away, :busy]
  ACCESS_TYPES = [:pending, :granted, :revoked]

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to  :topic,   :polymorphic => true,   :validate => false
  embedded_in :user,    :validate    => false

  field :name,          type: String
  field :position,      type: Integer,    default: 0
  field :access,        type: Symbol,     default: :pending

  validates :topic_id,   presence: true,  :exclusion => {
    :in => ->(conversation){ [conversation.user.id] },
    :message => "is the same as the conversation owner"
  }

  validates :topic_type, presence: true,  :inclusion => {
    :in => TOPIC_TYPES,
    :message => "is not a supported type"
  }

  validates :access,     presence: true,  :inclusion => {
    :in => ACCESS_TYPES,
    :message => "is not a supported type"
  }

  validates :position,   presence: true,  :numericality => {
    :greater_than_or_equal_to => 0
  }

  def self.sortie(by: nil, on: nil, as: :granted)
    conversation = by.conversations.find_or_initialize_by(topic: on)
    conversation.access = as

    if not by.conversations.include?(conversation)
      by.conversations << conversation
    end

    return conversation
  end

  def self.retreat(by: nil, from: nil)
    conversation = by.conversations.where(topic: from).first

    if by.conversations.include?(conversation)
      by.conversations.delete(conversation)
    end

    return conversation
  end

  # Public: Custom getter for the name preferring the
  # stored version to the name derrived from associated
  # topic.
  #
  # Returns a string, always.
  def name
    self[:name] || self.topic.name
  end

  # Public: Fetches the notification count for this
  # conversation from redis.
  #
  # Returns an integer.
  def notifications
    @notifications ||= $redis.get("#{redis_key}:notifications").try(:to_i) || 0
  end

  # Public: Determines the conversation status.
  # Returns a symbol.
  def access
    if @_access ||= $redis.get("#{redis_key}:access").try(:to_sym)
      return @access = @_access
    else
      return @access = self[:access]
    end
  end

  # Public: Determines the conversation status by proxy
  # to the related topic, if the topic has a concept of
  # status.
  #
  # Returns a Symbol, either :online, :offline, :away or :busy
  def status
    @status = topic.respond_to?(:status) ? topic.status : :online
  end

  # Public: Generate the redis key for this instance.
  # Returns a string.
  def redis_key
    "#{$redis_ns}:#{user.id}:conversations:#{topic_type.downcase}:#{topic_id}"
  end

  # TODO: Returns posts which belongs to the conversation
  # after the conversation was activated and before it was
  # frozen.
  def posts
  end

end
