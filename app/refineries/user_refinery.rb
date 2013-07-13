class UserRefinery < Arcane::Refinery

  def update
    [:name,:username,:avatar,:password,:remote_avatar_url,:preferred_status]
  end

end