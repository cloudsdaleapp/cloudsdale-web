class UserMailer < ActionMailer::Base
  default :from => "noreply@cloudsdale.org"
 
  def restore_mail(user)
    @user = user
    @url = user_restoration_url(@user,@user.restoration.token)
    mail(:to => user.email, :subject => "Cloudsdale Account Restoration - #{user.email}")
  end
  
end