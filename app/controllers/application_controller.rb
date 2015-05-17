class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def find_user_by_request_token(request)
    token_param = request.headers['uimp-token'] unless request.nil?
    return nil unless token_param

    # Check for a non expired token, and then find its user
    token = Token.find_by_access_token(token_param)
    return nil if token.nil? || token.expired?

    return User.find(token.user_id)
  end

  def find_user_by_params_login(params)
    user_param = params[:user_id]
    password_param = params[:password]

    return nil if (user_param.nil? || password_param.nil?)

    # Find a user and check that user exists and has the right password
    user = User.find_by(email: user_param)
    return nil if user.nil? || !user.valid_password?(password_param)

    return user
  end

  def render_error(error_array, http_status = nil)
    error = { error_code: error_array[0],
              error_description: error_array[1] }

    if http_status
      render json: error, status: http_status
    else
      render json: error
    end
  end

  def render_invalid_credentials_error(email = nil, user = nil, options = {suppress: false})
    if (!options[:suppress] && (email || user))
      user = User.find_by(email: email) if email #overwrite user if finding thru email
      send_notification_to(user, 'invalid_login_credentials') unless user.nil?
    end

    render_error(Errors::LIST[:invalid_credentials], :unauthorized)
  end

  def render_invalid_token_error(user = nil, options = {suppress: false})
    send_notification_to(user, 'invalid_access_token') if (!options[:suppress] && user)

    render_error(Errors::LIST[:invalid_token], :unauthorized)
  end


  def send_notification_to(user, event, options = {success: true})
    # send a message to user if the event is one of the user's current notifications
    # pass success: false if you want to send a failed message instead
    # NOTE: currently not checking for success or failure, just sending a message all the time

    return if (user.nil? || event.nil?)

    user_notifications = user.notifications.map(&:event)
    return unless (user_notifications.include? event)

    Uimp::Notification.notification_msg(user, event, request.remote_ip).deliver
  end

end
