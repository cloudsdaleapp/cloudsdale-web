require 'rabl/renderer'

class Message

  include AMQPConnector

  include Mongoid::Document

  attr_accessible :client_id, :content, :device

  attr_accessor :client_id

  embedded_in :chat
  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :drops, inverse_of: nil

  field :timestamp,   type: Time,    default: -> { Time.now }
  field :content,     type: String
  field :device,      type: String,   default: 'desktop'

  # Meta attributes
  field :urls,        type: Array,    default: []

  validates :timestamp,   :presence => true
  validates :content,     :presence => true
  validates :author,      :presence => true

  default_scope -> { includes(:author,:drops) }

  scope :old, -> { order_by([:timestamp,:desc]).skip(50) }

  after_save do
    enqueue! "faye", { channel: "/#{self.topic_type}s/#{self.topic_id}/chat/messages", data: self.to_hash }
  end

  # Public: Translates the Message object to a HASH string using RABL
  #
  # Examples
  #
  # @message.to_hash
  # # => { content: "..." }
  #
  # Returns a Hash string.
  def to_hash
    Rabl.render(self, 'api/v1/messages/base', :view_path => 'app/views', :format => 'hash')
  end

  def topic_type
    chat.topic._type.downcase
  end

  def topic_id
    chat.topic._id.to_s
  end

  def utc_timestamp
    self[:timestamp].utc
  end

  def content=(msg)

    # CAPSLOCK DAY
    # msg.upcase! if (Date.today.day == 28 && Date.today.month == 6) || (Date.today.day == 22 && Date.today.month == 10)

    msg.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "\\n"
    msg.gsub! /<br\/><br\/>/,"\\n"
    msg.gsub! /^\s*$/, ""

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
      self[:content] = msg[0..999] + "\n\n\nMessage exceeded the 1000 character limit and has been trimmed..."
    else
      self[:content] = msg
    end

  end

end
