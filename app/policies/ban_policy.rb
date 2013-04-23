class BanPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user_is_moderator?
  end

  def create?
    offender_is_present? and
    user_outranks_offender? and
    user_is_not_being_prosecuted?
  end

  def update?
    create?
  end

  def destroy?
    update?
  end


private

  def user_is_owner?
    jurisdiction.owner_id == user.id
  end

  def user_is_moderator?
    jurisdiction.moderator_ids.include? user.id
  end

  def user_is_not_being_prosecuted?
    offender.id != user.id
  end

  def offender_is_present?
    jurisdiction.user_ids.include? ban.offender.id
  end

  def user_outranks_offender?
    if user_is_owner?
      return true
    elsif user_is_moderator?
      (offender.id != jurisdiction.owner_id) and
      !jurisdiction.moderator_ids.include? offender.id
    else
      return false
    end
  end

  def jurisdiction
    record.jurisdiction
  end

  def offender
    record.offender
  end

end
