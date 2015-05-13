class Uimp::Notification < ActionMailer::Base
  default from: "uimp.test@gmail.com",
          subject: "Notification from UIMP"

  def notification_msg(user, event)
    @user = user
    @event = event
    @ip = request.remote_ip

    mail(to: @user.email, template: template_type)
  end


  private
  def template_type
    if    Notification::LOGIN_EVENTS.include? @event
      'login_events'
    elsif Notification::GET_ACCESS_TOKEN_EVENTS.include? @event
      'get_access_token_events'
    elsif Notification::INVALID_ACCESS_TOKEN_EVENTS.include? @event
      'invalid_access_tokens_events'
    elsif Notification::API_EVENTS.include? @event
      'general_response'
    else
      raise "(Notification mailer) API event not found: #{@event}"
    end
  end
end
