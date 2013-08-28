class ConversationPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    record.user == user
  end

  def update?
    show?
  end

  def create?
    show?
  end

  def destroy?
    show?
  end

end