class UserSerializer < ApplicationSerializer

  attribute :name,          key: :display_name
  attribute :symbolic_role, key: :role_name

  attributes :username, :status, :role, :avatar, :activity, :suspended

  def avatar
    avatar_id_type = object.email_hash.present? :email_hash : :id
    return object.dynamic_avatar_url(nil, avatar_id_type, :https)
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
