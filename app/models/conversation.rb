# encoding: utf-8
#
# Public: Conversations is a proxy object for objects where
# you should be able to access chat. The conversation is
# embedded within the record of the conversee rather than
# the topic of conversation itself.
class Conversation

  TOPIC_TYPES  = ["Cloud", "User"]
  ACCESS_TYPES = [:pending, :granted, :revoked]

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to  :topic,   :validate => false,   inverse_of: :references,    polymorphic: true
  belongs_to  :user,    :validate => false,   inverse_of: :conversations

  field :position,      type: Integer,    default: 0
  field :access,        type: Symbol,     default: :granted

  index( { access: 1 },   { name: "access_index",   background: true } )
  index( { position: 1 }, { name: "position_index", background: true } )

  index( { user_id: 1, topic_id: 1 } )

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

  after_initialize :set_record_type

  # Public: Builds a conversation for a user on
  # a topic. If conversation on the same topic
  # already exists, it will use that one.
  #
  #   user  - An existing user
  #   about - The topic of conversation
  #
  # Returns a conversation instance.
  def self.as(user, about: nil)
    self.find_or_initialize_by(user: user, topic: about)
  end

  # Public: Inverse of Conversation::for
  #
  #   topic - The topic of conversation
  #   as    - An existing user
  #
  # Returns a conversation instance.
  def self.about(topic, as: nil)
    self.as(as, about: topic)
  end

  # Public: Sets the access of the conversation access
  # to granted. Works for new and existing records.
  #
  # Returns true or false.
  def start
    self.access = :granted
    self.save
  end

  # Public: Sets the access of the conversation access
  # to revoked. Works for new and existing records.
  #
  # Returns true or false.
  def interrupt
    self.access = :revoked
    self.save
  end

  # Public: Sets the access of the conversation access
  # to pending. Works for new and existing records.
  #
  # Returns true or false.
  def await
    self.access = :pending
    self.save
  end

  # Public: Method to destroy end the conversation for
  # a user and remove it from his list. Works only for
  # existing records.
  #
  # Returns true or false.
  def stop
    self.new_record? ? false : self.destroy
  end

  # Public: Fetches the notification count for this
  # conversation from redis.
  #
  # Returns an integer with total notifications.
  def notifications
    @notifications ||= $redis.get("#{redis_key}:notifications").try(:to_i) || 0
  end

  # Public: Clears notifications for this conversation
  #
  # Returns 0, the number of notifications remaining.
  def clear_notifications
    $redis.set("#{redis_key}:notifications",0)
    @notifications = 0
  end

  # Public: Increment notifications by n.
  #
  # n - How many notifications to add.
  #
  # Returns an integer with total notifications.
  def add_notifications(n=0)
    @notifications = $redis.incrby("#{redis_key}:notifications",n)
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

  # Public: Generate the redis key for this instance.
  # Returns a string.
  def redis_key
    "#{$redis_ns}:conversations:#{id}"
  end

  # Public: Conversts conversation to a human readable
  # string.
  def to_s
    "conversation"
  end

private

  # Private: Sets the type of the object to Conversation
  # Returns "Conversation"
  def set_record_type
    self[:_type] = "Conversation"
  end

end
