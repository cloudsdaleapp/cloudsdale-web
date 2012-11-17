module Jurisdiction

  def has_banned?(user)
   self.bans_on(user).active.count >= 1
  end

  def keeps_a_record_on?(user)
    self.bans_on(user).count >= 1
  end

  def bans_on(user)
    self.bans.where(offender_id: user.id)
  end

  def offenders
   user_ids = self.bans.map { |ban| ban.offender_id }
   User.where :_id.in => user_ids.uniq
  end

end
