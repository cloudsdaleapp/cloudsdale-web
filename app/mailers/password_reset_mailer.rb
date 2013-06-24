class PasswordResetMailer < ActionMailer::Base

  layout 'email'

  default from: "Cloudsdale <noreply@cloudsdale.org>",
          return_path: 'Cloudsdale Support <ask@cloudsdale.org>',
          css:  :email

  def verification_mail(token)

    password_reset = PasswordReset.find(token)
    user           = password_reset.user
    url            = direct_password_verify_url(password_reset.token)

    subject        = "Cloudsdale password reset"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'verification_mail.text.erb',   locals: { user: user, url: url, code: token }, layout: false }
      format.html { render 'verification_mail.html.haml',  locals: { user: user, url: url, code: token, subject: subject } }
    end

  end

  def confirmation_mail(user_id)
    user           = User.find(user_id)
    subject        = "Your password has been changed!"

    mail(to: user.email, subject: subject) do |format|
      format.text { render 'confirmation_mail.text.erb',   locals: { user: user }, layout: false }
      format.html { render 'confirmation_mail.html.haml',  locals: { user: user, subject: subject } }
    end
  end

end
