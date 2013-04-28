require 'sendgrid/header'

class DispatchMailer < ActionMailer::Base

  layout 'email'

  default from: "Cloudsdale <noreply@cloudsdale.org>",
          return_path: 'Cloudsdale Support <ask@cloudsdale.org>',
          css:  :email

  def default_mail(dispatch_id,user_id,mail_id)

    hdr = SendGridHeader.new
    hdr.addCategory "dispatch:#{dispatch_id}"

    dispatch = Dispatch.find(dispatch_id)
    user     = User.find(user_id)

    headers["X-SMTPAPI"] = hdr.to_json

    mail(to: user.email, subject: dispatch.subject) do |format|
      format.text { render 'default_mail.text.erb',   locals: { user: user, dispatch: dispatch, subject: dispatch.subject }, layout: false }
      format.html { render 'default_mail.html.haml',  locals: { user: user, dispatch: dispatch, subject: dispatch.subject } }
    end

  end

end
