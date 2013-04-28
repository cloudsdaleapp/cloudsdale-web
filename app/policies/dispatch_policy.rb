class DispatchPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user.is_of_role? :admin
  end

  def show?
    index?
  end

  def create?
    show?
  end

  def update?
    create?
  end

  def destroy?
    update?
  end

end
