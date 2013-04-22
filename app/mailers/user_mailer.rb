class UserMailer < ActionMailer::Base

  layout 'email'

  default from: "Cloudsdale <noreply@cloudsdale.org>",
          css:  :email

  def restore_mail(user_id)
    @user = User.find(user_id)
    @url = restore_users_url(@user.restoration.token)
    @subject = "Cloudsdale Account Restoration"
    mail(
      :to => @user.email,
      :subject => "Cloudsdale Account Restoration - #{@user.email}"
    )
  end

end
