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

  attr_accessible :due, :revoke, :reason, :offender

  validates :due,    presence: true
  validates :reason, length: { within: 1..140 }, presence: true
  validate :validate_due, if: :due_changed?

  scope :revoked, where(revoke: true)
  scope :expired, -> { where(:due.lt => DateTime.current) }
  scope :active,  -> { where(:due.gt => DateTime.current, :revoke => false) }
  scope :on_user, -> user { where(:offender_id => user.id) }
  scope :by_user, -> user { where(:enforcer_id => user.id) }

  after_save do
    enqueue! "faye", { channel: "/users/#{self.offender_id}/bans", data: self.to_hash }
  end

  # Public: Record factory to build find an existing ban for an offender or
  # build a new ban, filtering the parameters through the ban refinery.
  #
  # Returns a ban record.
  def self.refined_build(params, enforcer: nil, offender: nil, jurisdiction: nil)
    params = ActionController::Parameters.new(params)
    ban = jurisdiction.bans.find_or_initialize_by(offender: offender).tap do |record|
      record.offender = offender
      record.enforcer = enforcer
      record.assign_attributes(params.for(record).as(enforcer).on(:create).refine)
    end
    jurisdiction.bans.push(ban) unless jurisdiction.bans.map(&:_id).include?(ban.id)
    return ban
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

  # Public: Custom setter for due which limits the the due for a
  # ban to a maximum of one year.
  #
  # Returns the final set value for the ban.
  def due=(time = 1.day.from_now)
    time = time.to_time.utc if time.kind_of?(String)
  rescue ArgumentError
    time = 1.day.from_now.utc
  ensure
    time = 1.year.from_now.utc if time > 1.year.from_now.utc
    super(time)
  end

  # Public: Custom setter for revoke that will transform nil to
  # a default value and sanitize any other parameters.
  #
  # Returns the set value.
  def reason=(text = DEFAULT_REASON)
    super(text.strip) if text.kind_of?(String)
  end

  # Public: Custom setter for revoke that will transform nil to
  # a default value.
  #
  # Returns the set value.
  def revoke=(value=false)
    super(value)
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
