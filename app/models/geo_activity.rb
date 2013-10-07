class GeoActivity

  include Mongoid::Document

  embedded_in :user

  field :_id,          type: String
  field :date,         type: String,   default: -> { DateTime.current.utc.to_date }
  field :loc,          type: Array,    default: [ 0.0, 0.0 ]
  field :country_code, type: String
  field :city,         type: String

  def self.record(ip: nil, user: nil)
    date     = DateTime.current.utc.to_date
    activity = user.geo_activities.find_or_initialize_by(_id: ip, date: date) do |activity|
      geo                   = $geoip.look_up(ip)
      activity.id           = ip
      activity.city         = geo[:city]
      activity.country_code = geo[:country_code3]
      activity.loc          = [ geo[:longitude], geo[:latitude] ]
    end
    return activity
  end

  def self.record!(ip: nil, user: nil)
    activity = self.record(ip: nil, user: nil)
    activity.save if activity.new_record?
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