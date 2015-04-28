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

  def render_invalid_credentials_error
    render_error(Errors::LIST[:invalid_credentials], :unauthorized)
  end

  def render_invalid_token_error
    render_error(Errors::LIST[:invalid_token], :unauthorized)
  end

end
