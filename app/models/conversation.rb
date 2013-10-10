# encoding: utf-8
#
# Public: Conversations is a proxy object for objects where
# you should be able to access chat. The conversation is
# embedded within the record of the conversee rather than
# the topic of conversation itself.
class Conversation

  TOPIC_TYPES  = ["Cloud", "User"]
  ACCESS_TYPES = [:requesting, :locked, :pending, :granted, :revoked]

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to  :topic,   :validate => false,   inverse_of: :references,    dependent: :nullify, polymorphic: true
  belongs_to  :user,    :validate => false,   inverse_of: :conversations, dependent: :nullify

  after_create  :topic_participants_increment!, :if => -> (convo) { [Cloud].include? convo.topic.class }
  after_destroy :topic_participants_decrement!, :if => -> (convo) { [Cloud].include? convo.topic.class }
  after_create  :user_conversations_increment!
  after_destroy :user_conversations_decrement!

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

  def self.refined_build(params, user: nil)
    hash  = params.require(:conversation)
    topic = { topic_id: nil, topic_type: nil, user: user }

    if _topic = hash.permit(topic: [:id, :type])[:topic]
      topic[:topic_id]   = _topic[:id]
      topic[:topic_type] = _topic[:type]
    else
      topic[:topic_id]   = hash[:topic_id]
      topic[:topic_type] = hash[:topic_type]
    end

    return self.find_or_initialize_by(topic) do |convo|
      convo.write_attributes(params.for(convo).as(user).on(:create).refine)
    end

  end

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

  # Public: Request mock conversation for user
  def self.request(user: nil, topic: nil)
    self.new(user: user, topic: topic, access: :requesting)
  end

  def topic_type=(value)
    super(value.strip.classify) if value
  end

  # Public: Sets the access of the conversation access
  # to granted. Works for new and existing records.
  #
  # Returns true or false.
  def start
    self.access = :granted

    # Legacy transaction
    if topic.kind_of?(Cloud)
      user.clouds.push(topic)
      topic.users.push(user)

      topic.save
      user.save
    end

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

    # Legacy transaction
    if topic.kind_of?(Cloud)
      user.clouds_moderated.delete(topic)
      user.clouds.delete(topic)

      topic.moderators.delete(user)
      topic.users.delete(user)

      topic.save
      user.save
    end

    self.new_record? ? false : self.destroy
  end

  def messages(before: nil, since: nil, limit: nil)
    criteria = case topic_type
    when "User"
      Message.and(:topic_id.in => [topic_id, user_id], :author_id.in => [user_id, topic_id])
    when "Cloud"
      Message.where(topic: topic)
    end

    criteria = criteria.includes(:author)
    criteria = criteria.order_by(created_at: :desc)
    criteria = criteria.where(:created_at.lt => before) if before
    criteria = criteria.where(:created_at.gt => since)  if since
    criteria = criteria.limit(limit) if limit
    return criteria
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

  # Public: Generates the channel name to which users
  # should subscribe for updates.
  #
  # Returns a string.
  def channel_name
    @channel_name ||= "/v2/#{user_id}/convo/#{topic_id}"
  end

private

  # Private: Sets the type of the object to Conversation
  # Returns "Conversation"
  def set_record_type
    self[:_type] = "Conversation"
  end

  # Private: Increase topic participant count by one
  def topic_participants_increment!; topic.inc(:participant_count, 1)   if topic.present?; end
  # Private: Decrease topic participant count by one
  def topic_participants_decrement!; topic.inc(:participant_count, -1)  if topic.present?; end
  # Private: Increase user conversation count by one
  def user_conversations_increment!; user.inc(:conversation_count, 1)   if user.present?; end
  # Private: Decrease user conversation count by one
  def user_conversations_decrement!; user.inc(:conversation_count, -1)  if user.present?; end

end
