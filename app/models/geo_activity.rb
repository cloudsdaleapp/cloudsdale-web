class GeoActivity

  include Mongoid::Document

  embedded_in :user

  field :_id,          type: String
  field :dates,        type: Array,    default: -> { [DateTime.current.utc.to_date.to_s] }
  field :loc,          type: Array
  field :country_code, type: String
  field :city,         type: String

  def self.record(ip: nil, user: nil)
    date     = DateTime.current.utc.to_date.to_s

    activity = user.geo_activities.where(_id: ip).first
    activity ||= user.geo_activities.new
    geo      = $geoip.look_up(ip)

    if activity && geo
      activity.id           ||= ip
      activity.city         ||= geo[:city]
      activity.country_code ||= geo[:country_code3]
      activity.loc          ||= [ geo[:longitude], geo[:latitude] ]
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

  def longitude; loc[0]; end
  alias :lng :longitude

  def latitude; loc[1]; end
  alias :lat :latitude


end