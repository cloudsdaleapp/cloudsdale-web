class MessagePolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def create?
    (user_is_not_banned_from_topic? and
    user_is_member_of_topic? and
    user_is_author? and
    topic_is_unlocked?) or
    user.is_of_role? :admin
  end

  def update?
    create?
  end

  def destroy?
    user_is_author? or
    user.is_of_role? :admin
  end

private

  def user_is_author?
    record.author.id == user.id
  end

  def user_is_member_of_topic?
    record.topic.user_ids.include? user.id
  end

  def topic_is_unlocked?
    not record.topic.locked?
  end

  def user_is_not_banned_from_topic?
    not record.topic.has_banned? user
  end

end
