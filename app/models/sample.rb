# encoding: utf-8
#
# Public: Samples are statistics gathered for a specific day.
# Samples can be used as a medium to aggregate different data
# on Cloudsdale without querying users and clouds directly.
class Sample

  include Mongoid::Document
  include Mongoid::Timestamps

  field :date,                type: String
  field :start_time,          type: DateTime
  field :stop_time,           type: DateTime
  field :user_statistics,     type: Hash,       default: {}
  field :cloud_statistics,    type: Hash,       default: {}
  field :drop_statistics,     type: Hash,       default: {}
  field :message_statistics,  type: Hash,       default: {}

  before_save :generate_statistics

  def self.build_for_date(date)
    Sample.find_or_initialize_by date: date.to_date.to_s
  end

  def self.generate_statistics_for_date_range(first_date,last_date)
    first_date ||= 1.day.ago
    last_date  ||= Date.today
    (first_date.to_date..last_date.to_date).each do |date|
      puts "-> Generating Sample for #{date}"
      sample = Sample.build_for_date(date)
      sample.generate_statistics
      sample.save
      puts "-> Proccessed Sample for #{date}, successfully"
    end
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
    generate_message_statistics
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

  def generate_message_statistics
    self.message_statistics[:new]   = Message.where(:created_at.gt => self.start_time, :created_at.lt => self.stop_time).count
    self.message_statistics[:total] = Message.where(:created_at.lt => self.stop_time).count
  end

end
