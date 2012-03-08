module MainHelper
  
  def user_accepted_tnc?
    !current_user.tnc_last_accepted.nil?
  end
  
  def user_has_avatar?
    !current_user.avatar.url.nil?
  end
  
  def user_is_member_of_cloud?
    current_user.cloud_ids.count >= 1
  end
  
  def user_has_contributed?
    Drop.where("deposits.depositable_id" => current_user.id).count >= 1
  end
  
  def user_got_started?
    user_accepted_tnc? && user_has_avatar? && user_is_member_of_cloud? && user_has_contributed?
  end
  
end
