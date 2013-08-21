class Ban

  DEFAULT_REASON = "No reason."

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps

  field :reason,  type: String,     default: DEFAULT_REASON
  field :due,     type: DateTime,   default: -> { 1.day.from_now }
  field :revoke,  type: Boolean,    default: false

  embedded_in :jurisdiction

  belongs_to :offender, :class_name => "User", inverse_of: nil
  belongs_to :enforcer, :class_name => "User", inverse_of: nil

  attr_accessible :due,     as: [:editor,:enforcer]
  attr_accessible :revoke,  as: [:editor]
  attr_accessible :reason,  as: [:enforcer]

  validates :due,    presence: true
  validates :reason, length: { within: 1..140 }, presence: true
  validate :validate_due, if: :due_changed?

  scope :active, where(:due.gt => DateTime.current, :revoke => false)
  scope :revoked, where(revoke: true)
  scope :expired, where(:due.lt => DateTime.current)
  scope :on_user, -> user { where(:offender_id => user.id) }
  scope :by_user, -> user { where(:enforcer_id => user.id) }

  after_save do
    enqueue! "faye", { channel: "/users/#{self.offender_id}/bans", data: self.to_hash }
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

  def due=(time)
    time =|| 1.day.from_now
    time = 1.years.from_now if time > 1.year.from_now
    super(time)
  end

  def reason=(text)
    text =|| DEFAULT_REASON
    super(text.strip)
  end

  def revoke=(value=false)
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
