ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {  
  :address              => "mailcluster.loopia.se",  
  :port                 => 587,
  :user_name            => "noreply@cloudsdale.org",
  :domain               => "cloudsdale.org",
  :password             => "w94MJq25233S143",
  :authentication       => :login,
  :enable_starttls_auto => true
}