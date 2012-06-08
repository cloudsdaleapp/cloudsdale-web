class UserMailer < ActionMailer::Base
  default :from => "noreply@cloudsdale.org"
 
  def restore_mail(user)
    @user = user
    @url = restore_users_url(@user.restoration.token)
    mail(:to => user.email, :subject => "Cloudsdale Account Restoration - #{user.email}")
  end
  
  def beta_mail(user)
    @user = user
    mail(:to => user.email, :subject => "Cloudsdale - We're out of beta.")
  end
  
end