class UserSerializer < ApplicationSerializer

  attribute :name,          key: :display_name
  attribute :symbolic_role, key: :role_name

  attributes :username, :status, :role, :avatar, :activity, :suspended

  def avatar
    Rails.env.development? ? Cloudsdale.config['url'] + object.avatar.url : object.avatar.url
  end

  def activity
    recent_dates_seen = Hash.new

    (7.days.ago.to_date..Date.today).each do |date|
      recent_dates_seen[date.to_s] = object.dates_seen.include?(date.to_s) ? 1 : 0
    end

    return recent_dates_seen
  end

  def suspended
    object.banned?
  end

end
