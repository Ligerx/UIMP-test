class Uimp::Notification < ActionMailer::Base
  default from: "uimp.test@gmail.com",
          subject: "Notification from UIMP"

  def notification_msg(user, event, ip)
    @user = user
    @event = event
    @ip = ip # mailer has no access to request, so pass the ip in myself

    mail(to: @user.email, template_name: template_type) #, template_path: 'uimp/notification')
  end


  private
  def template_type
    if    Notification::LOGIN_EVENTS.include? @event
      'login_events'
    elsif Notification::GET_ACCESS_TOKEN_EVENTS.include? @event
      'get_access_token_events'
    elsif Notification::INVALID_CREDENTIAL_EVENTS.include? @event
      'invalid_credential_events'
    elsif Notification::API_EVENTS.include? @event
      'general_response'
    else
      raise "(Notification mailer) API event not found: #{@event}"
    end
  end
end
