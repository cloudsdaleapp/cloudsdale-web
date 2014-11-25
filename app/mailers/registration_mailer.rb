class RegistrationMailer < ActionMailer::Base

  layout 'email'

  default from: "Cloudsdale <noreply@cloudsdale.org>",
          return_path: 'Cloudsdale Support <ask@cloudsdale.org>',
          css:  :email

  def verification_mail(token)
    registration = Registration.find(token)
    url          = direct_register_verification_url(token)
    user         = registration.to_user
    subject      = "Complete cloudsdale registration"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'verification_mail.text.erb',   locals: { user: user, url: url, code: token }, layout: false }
      format.html { render 'verification_mail.html.haml',  locals: { user: user, url: url, code: token, subject: subject } }
    end
  rescue Mongoid::Errors::DocumentNotFound
  end

end
