class MessagePolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def create?
    (user_is_not_banned_from_topic? and
    user_is_member_of_topic? and
    topic_is_unlocked?) or
    user.is_of_role? :admin
  end

  def update?
    create?
  end

private

  def user_is_member_of_topic?
    record.chat.topic.user_ids.include? user.id
  end

  def topic_is_unlocked?
    not record.chat.topic.locked?
  end

  def user_is_not_banned_from_topic?
    not record.chat.topic.has_banned? user
  end

end
