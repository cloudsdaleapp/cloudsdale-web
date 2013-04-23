class CloudPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def update?
    record.owner_id == user.id
  end

  def create?
    (user_registered_days_ago? 10 and
    user_own_less_clouds_than? 1 ) or
    user.is_of_role?(:admin)
  end

  def destroy?
    update?
  end

  def join?
    not record.has_banned? user
  end

  def leave?
    record.user_ids.include? user.id
  end

private

  def user_registered_days_ago?(n = 10)
    n.days.ago > user.created_at
  end

  def user_own_less_clouds_than?(n = 1)
    user.owned_clouds.count < n
  end

end
