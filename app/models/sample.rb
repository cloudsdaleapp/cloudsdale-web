# encoding: utf-8
#
# Public: Samples are statistics gathered for a specific day.
# Samples can be used as a medium to aggregate different data
# on Cloudsdale without querying users and clouds directly.
class Sample

  include Mongoid::Document
  include Mongoid::Timestamps

  field :date,              type: String
  field :start_time,        type: DateTime
  field :stop_time,         type: DateTime
  field :user_statistics,   type: Hash,       default: {}
  field :cloud_statistics,  type: Hash,       default: {}
  field :drop_statistics,   type: Hash,       default: {}

  before_save :generate_statistics

  def self.build_for_date(date)
    Sample.find_or_initialize_by date: date.to_date.to_s
  end

  def date=(_date)
    self.start_time = _date.to_datetime
    self.stop_time  = _date.to_datetime
    self[:date]     = _date.to_date.to_s
  end

  def start_time=(_datetime)
    self[:start_time] = _datetime.beginning_of_day
  end

  def stop_time=(_datetime)
    self[:stop_time]  = _datetime.end_of_day
  end

  def generate_statistics
    generate_cloud_statistics
    generate_user_statistics
    generate_drop_statistics
    true
  end

private

  def generate_cloud_statistics
    self.cloud_statistics[:new]   = Cloud.where(:created_at.gt => self.start_time, :created_at.lt => self.stop_time).count
    self.cloud_statistics[:total] = Cloud.where(:created_at.lt => self.stop_time).count
  end

  def generate_user_statistics
    self.user_statistics[:new]    = User.where(:created_at.gt => self.start_time, :created_at.lt => self.stop_time).count
    self.user_statistics[:total]  = User.where(:created_at.lt => self.stop_time).count
    self.user_statistics[:active] = User.where(:dates_seen.in => [self.date]).count
  end

  def generate_drop_statistics
    self.drop_statistics[:new]   = Drop.where(:created_at.gt => self.start_time, :created_at.lt => self.stop_time).count
    self.drop_statistics[:total] = Drop.where(:created_at.lt => self.stop_time).count
  end

end
