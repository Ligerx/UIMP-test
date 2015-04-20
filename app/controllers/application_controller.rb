class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def find_user(params)
    token_param = params[:access_token]
    email_param = params[:user_id]
    email_old_password = params[:old_password]

    if token_param
      # Check for a non expired token, and then find its user
      token = Token.find_by_access_token(token_param)
      @new_password = params[:password]

      return nil if token.nil? || token.expired?

      return User.find_by_email(token.user_id)

    elsif email_param && email_old_password
      # Find a user and check that user exists and has the right password
      user = User.find_by_email(email_param)
      @new_password = params[:new_password]

      return nil if user.nil? || !user.valid_password?(email_old_password)

      return user
    else
      nil
    end
  end

end
