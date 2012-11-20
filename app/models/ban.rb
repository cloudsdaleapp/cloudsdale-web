class Ban

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps

  field :reason,  type: String
  field :due,     type: DateTime,   default: -> { 2.days.from_now }
  field :revoke,  type: Boolean,    default: false

  embedded_in :jurisdiction

  belongs_to :offender, :class_name => "User", inverse_of: nil
  belongs_to :enforcer, :class_name => "User", inverse_of: nil

  attr_accessible :due,     as: [:editor,:enforcer]
  attr_accessible :revoke,  as: [:editor]
  attr_accessible :reason,  as: [:enforcer]

  validates :reason, length: { within: 1..140 }
  validates :due
  validate :validate_due

  scope :active, where(:due.gt => DateTime.current, :revoke => false)
  scope :revoked, where(revoke: true)
  scope :expired, where(:due.lt => DateTime.current)

  after_save do
    enqueue! "faye", { channel: "/#{jurisdiction._type}s/#{jurisdiction._id.to_s}/bans", data: self.to_hash }
  end

  # Public: Translates the Ban object to a HASH string using RABL
  #
  #   args - A Hash of arguments to be sent to the rabl, renderer.
  #
  # Examples
  #
  # @cloud.to_hash
  # # => { name: "..." }
  #
  # Returns a Hash.
  def to_hash(args={})
    defaults = { template: "api/v1/bans/base", view_path: 'app/views' }
    options = defaults.merge(args)

    Rabl.render(self, options[:template], :view_path => options[:view_path], :format => 'hash')
  end

private

  # Checks if due date is in the future
  # Returns a Boolean or nil
  def due_in_future
    self.due.try(:future?)
  end

  # Used to validate due date
  # Returns errors if you fucked up.
  def validate_due
    errors.add("due", "must be in the future") unless due_in_future
  end

end
