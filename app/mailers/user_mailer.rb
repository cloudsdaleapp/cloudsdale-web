class UserMailer < ActionMailer::Base

  default :from => "Cloudsdale <noreply@cloudsdale.org>"

  def restore_mail(user_id)
    @user = User.find(user_id)
    @url = restore_users_url(@user.restoration.token)
    mail(
      :to => @user.email,
      :subject => "Cloudsdale Account Restoration - #{@user.email}"
    )
  end

end
