class UserPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def update?
    record == user
  end

  def create?
    not user.is_registered?
  end

  def destroy?
    record == user
  end

end
