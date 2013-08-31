class SpotlightPolicy < ApplicationPolicy

  def create?
    user.is_of_role? :admin
  end

  def update?
    create?
  end

end
