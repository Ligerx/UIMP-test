class Uimp::AccountController < ApplicationController

  def change_password #CHANGE TO ALLOW TOKENS
    # resource = User.find_by_email(params[:user_id]) # does this need strong parameters?

    # unless resource
    #   render json: {error_code: 1, error_description: "Could not find user"} and return
    # end

    # begin
    #   resource.update_with_password(change_password_params)
    # rescue ForbiddenAttributesError
    #   render json: {error_code: 2, error_description: "Problem changing password with given info"}
    # end
    
    # render json: {}
Rails::logger.debug "PARAMS: #{change_password_params}"
    user = find_user
Rails::logger.debug "USER: #{user}"

    if user.nil?
      render json: {error_code: 2, error_description: "Invalid credentials"} and return
    end

    if user.update_attributes(change_password_params)
      render json: {} and return
    else
      render json: {error_code: 3, error_description: "Error updating password"} and return
    end

  end



  private
  def change_password_params
    # Devise requires these particular key names.
    # Doing it this way is simpler than renaming through strong parameters.
    # allowed_values = {email: params[:user_id], current_password: params[:old_password], password: params[:new_password]}

    # params.permit(:email, :current_password, :password)
    # params.permit(:user_id, :old_password, :new_password)
    params.permit(:email, :current_password, :password, :user_id, :old_password, :new_password)

    reformat_params

    params
  end

  def reformat_params
    params[:email] = params.delete(:user_id) if params[:user_id]
    params[:current_password] = params.delete(:old_password) if params[:old_password]
    params[:password] = params.delete(:new_password) if params[:new_password]
  end

  def find_user
    token_param = change_password_params[:access_token]
    email_param = change_password_params[:email]
    password_param = change_password_params[:current_password]

    if token_param
      # Check for a non expired token, and then find its user
      token = Token.find_by_access_token(token_param)
      return nil if token.expired?

      User.find_by_email(token.user_id)
    elsif email_param && password_param
      # Find a user and check that user exists and has the right password
      user = User.find_by_email(email_param)
      return nil unless user && user.valid_password?(password_param)

      user
    end

    return nil
  end

end
