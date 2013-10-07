class GeoActivity

  include Mongoid::Document

  embedded_in :user

  attr_accessible :_id, :dates, :city, :loc, :country_code, :city

  field :_id,          type: String,   default: nil
  field :dates,        type: Array,    default: -> { [DateTime.current.utc.to_date.to_s] }
  field :loc,          type: Array
  field :country_code, type: String
  field :city,         type: String

  scope :with_location, where(:loc.ne => nil)

  validates :_id,   presence: true,  uniqueness: true
  validates :dates, presence: true

  def self.record(ip: nil, user: nil)
    date     = DateTime.current.utc.to_date.to_s

    activity = user.geo_activities.find_or_initialize_by(_id: ip.to_s)
    geo      = $geoip.look_up(ip)

    if activity && geo
      activity.id           = ip
      activity.city         = geo[:city]
      activity.country_code = geo[:country_code3]
      activity.loc          = [ geo[:longitude], geo[:latitude] ]
      activity.dates        << date unless activity.dates.include?(date)
    end

    return activity
  end

  def self.record!(ip: nil, user: nil)
    activity = self.record(ip: ip, user: user)
    activity.save if activity.new_record? || activity.changed?
    return activity
  end

  def date=(value)
    super(value.to_date.to_s)
  end

  def loc=(point)
    super(point.map(&:to_f)) if point[0].present? and point[1].present?
  end

  def longitude; loc[0]; end
  alias :lng :longitude

  def latitude; loc[1]; end
  alias :lat :latitude

  def last_date
    dates.sort.reverse.first
  end

  def first_date
    dates.sort.first
  end

end