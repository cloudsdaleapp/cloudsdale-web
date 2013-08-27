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

  index( { _id: 1 }, { name: 'id_index' } )
  index( { created_at: -1, topic_id: 1 }, { name: 'conversation_index' } )

  validates :content,  presence: true
  validates :author,   presence: true
  validates :topic,    presence: true

  def content=(msg)

    msg.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "\\n"
    msg.gsub! /<br\/><br\/>/,"\\n"
    msg.gsub! /^\s*$/, ""

    msg.gsub! /(https\:\/\/www.cloudsdale.org)/i, "http://www.cloudsdale.org"

    if (m = msg.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\!\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i do

        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path

        self[:urls] ||= []
        self[:urls] << url

        url
      end
    end

    if msg.present? && msg.length > 1000
      self[:content] = msg[0..999] + "\\n\\n\\nMessage exceeded the 1000 character limit and has been trimmed..."
    else
      self[:content] = msg
    end

  end

  # Deprecated Attributes
  field :urls, type: Array, default: []
  field :timestamp,   type: Time,     default: -> { Time.now }
  has_and_belongs_to_many :drops, inverse_of: nil
  default_scope -> { includes(:author,:drops) }
  scope :old, -> { order_by([:timestamp,:desc]).skip(50) }
  after_save :v1_publish

  # Deprecated Methods
  def utc_timestamp
    self[:timestamp].utc
  end

private

  def v1_publish
    rendered_content = Rabl.render(self, 'api/v1/messages/base', :view_path => 'app/views', :format => 'hash')
    enqueue! "faye", { channel: "/#{self.topic_type.downcase}s/#{self.topic_id.to_s}/chat/messages", data: rendered_content }
  end

end
