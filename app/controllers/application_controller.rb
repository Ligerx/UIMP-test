class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  # def find_user(params, request = nil)
    # token_param = request.headers['uimp-token'] unless request.nil?
    # email_param = params[:user_id]
    # email_old_password = params[:old_password]

    # if token_param
    #   # Check for a non expired token, and then find its user
    #   token = Token.find_by_access_token(token_param)
    #   @new_password = params[:password]

    #   return nil if token.nil? || token.expired?

    #   return User.find(token.user_id)

    # elsif email_param && email_old_password
    #   # Find a user and check that user exists and has the right password
    #   user = User.find_by(email: email_param)
    #   @new_password = params[:new_password]

    #   return nil if user.nil? || !user.valid_password?(email_old_password)

    #   return user
    # else
    #   nil
    # end

    ### REMAKE
    # token_param = request.headers['uimp-token'] unless request.nil?
    # user_param = params[:user_id]
    # password_param = params[:password]

    # if token_param
    #   # Check for a non expired token, and then find its user
    #   token = Token.find_by_access_token(token_param)

    #   return nil if token.nil? || token.expired?
    #   return User.find(token.user_id)

    # elsif user_param && password_param
    #   # Find a user and check that user exists and has the right password
    #   user = User.find_by(email: user_param)

    #   return nil if user.nil? || !user.valid_password?(password_param)
    #   return user

    # else
    #   nil
    # end

  # end

  # def find_user(info)
  #   # info can either be params or request
  # end

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

  def render_error(error_array)
    render json: { error_code: error_array[0],
                   error_description: error_array[1] }
  end

  def render_invalid_credentials_error
    render_error(Errors::LIST[:invalid_credentials])
  end

  def render_invalid_token_error
    render_error(Errors::LIST[:invalid_token])
  end

end
