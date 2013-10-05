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

  validates :content,  presence: true
  validates :author,   presence: true
  validates :topic,    presence: true

  def self.refined_build(params, author: nil, topic: nil)
    return self.new do |message|
      message.write_attributes(params.for(self).as(author).on(:create).refine)
      message.author = author
      message.topic  = topic
    end
  end

  def content=(value)
    value.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "\\n"
    value.gsub! /<br\/><br\/>/,"\\n"
    value.gsub! /^\s*$/, ""

    super(value[0..1000])
  end

  # Deprecated Attributes
  has_and_belongs_to_many :drops, inverse_of: nil
  default_scope -> { includes(:author,:drops) }
  after_save :v1_publish

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
