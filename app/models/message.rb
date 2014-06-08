require 'rabl/renderer'

class Message

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :client_id

  belongs_to :author, class_name: "User", :validate => false,   autosave: false
  belongs_to :topic,  polymorphic: true,  :validate => false,   autosave: false

  field :content,     type: String
  field :device,      type: String,   default: 'desktop'

  index( { created_at: -1 }, { name: 'created_at_index' } )
  index( { topic_id:   1, created_at: -1 }, { name: 'conversation_index' } )
  index( { topic_id:   1, author_id: 1, created_at: -1 }, { name: 'private_conversation_index' } )

  validates :content,  presence: true
  validates :author,   presence: true
  validates :topic,    presence: true

  def self.refined_build(params, author: nil, topic: nil, convo: nil)
    topic  ||= convo.topic
    author ||= convo.user

    return self.new do |message|
      message.write_attributes(params.for(message).as(author).on(:create).refine)
      message.author = author
      message.topic  = topic
    end
  end

  def refined_update(params, editor: nil)
    params = params.for(self)
    params = params.as(editor) unless editor.nil?
    params = params.on(:update)
    update_attributes(params.refine)
  end

  def content=(value)
    if value
      # Normalize Unicode Linebreaks
      value.gsub!(/[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "\\n")

      # Normalize HTML Linebreaks
      value.gsub!(/<br\/><br\/>/,"\\n")

      # Remove Value with only spaces
      value.gsub!(/^\s+$/, "")

      # Translation according to act 1:1 of Cloudsdale law
      value.gsub!(/Banned/, "Bent" )
      value.gsub!(/banned/, "bent")
      value.gsub!(/BANNED/, "BENT" )
      value.gsub!(/banned/i, "bent" )

      # Limit Value to 1k characters
      super(value[0..1000])
    end
  end

  # Deprecated Attributes
  has_and_belongs_to_many :drops, inverse_of: nil
  default_scope -> { includes(:author,:drops) }
  after_create :v1_publish

  # Deprecated Methods
  def utc_timestamp
    timestamp.utc
  end

  def timestamp
    (self.created_at || DateTime.current).to_time
  end

private

  def v1_publish
    rendered_content = Rabl.render(self, 'api/v1/messages/base', :view_path => 'app/views', :format => 'hash')
    enqueue! "faye", { channel: "/#{self.topic_type.downcase}s/#{self.topic_id.to_s}/chat/messages", data: rendered_content }
  end

end
