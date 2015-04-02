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

    if user.update(password: @new_password)
      render json: {} and return
    else
      render json: {error_code: 3, error_description: "Error updating password"} and return
    end

  end



  private
  def change_password_params
    params.permit(:access_token, :password, :user_id, :old_password, :new_password)
  end

  def find_user
    token_param = change_password_params[:access_token]
    email_param = change_password_params[:user_id]
    email_old_password = change_password_params[:old_password]

Rails::logger.debug "INSIDE FIND_USER"
Rails::logger.debug "token #{token_param},    email #{email_param},     old password #{email_old_password}"


    if token_param
Rails::logger.debug "INSIDE FIND_USER TOKEN"

      # Check for a non expired token, and then find its user
      token = Token.find_by_access_token(token_param)
      @new_password = change_password_params[:password]

      return nil if token.nil? || token.expired?

      return User.find_by_email(token.user_id)

    elsif email_param && email_old_password
Rails::logger.debug "INSIDE FIND_USER email+password"

      # Find a user and check that user exists and has the right password
      user = User.find_by_email(email_param)
      @new_password = change_password_params[:new_password]

Rails::logger.debug "user: #{user}"
Rails::logger.debug "@new_password: #{@new_password}"
Rails::logger.debug "user.nil? #{user.nil?}"
Rails::logger.debug "valid_password? #{user.valid_password?(email_old_password)}"



      return nil if user.nil? || !user.valid_password?(email_old_password)

      return user

    end

Rails::logger.debug "wtf return nil at end of method"
    return nil
  end

end
