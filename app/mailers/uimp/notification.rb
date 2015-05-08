class Uimp::Notification < ActionMailer::Base
  default from: "uimp.test@gmail.com"

  def notification_msg(user, event)
    # I'm going under the assumption that a message is only sent if the api call fails
    @user = user
    @event = event
    @ip = request.remote_ip
    mail(to: user.email, subject: "UIMP error: #{event}")
  end
end
