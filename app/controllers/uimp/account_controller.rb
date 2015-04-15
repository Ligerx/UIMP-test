class Uimp::AccountController < ApplicationController

  def create_account
    @new_user = User.new(create_account_params)

    if @new_user.save
      # not sure how to redirect to additional login procedures
      # this site's simple login does not have this functionality
      render json: { redirect_url: root_url }
    else
      render json: { redirect_url: root_url, error_code: 1, error_description: "Unable to create account with the given information" }
    end
  end

  def change_password
    user = find_user

    if user.nil?
      render json: {error_code: 2, error_description: "Invalid credentials"} and return
    end

    if user.update(password: @new_password)
      render json: {} and return
    else
      render json: {error_code: 3, error_description: "Error updating password"} and return
    end
  end

  def request_password_recovery
    
  end

  def update_account
    
  end


  private
  def create_account_params
    params.permit(:email, :password, :password_confirmation)
  end

  def change_password_params
    params.permit(:access_token, :password, :user_id, :old_password, :new_password)
  end

  def find_user
    token_param = change_password_params[:access_token]
    email_param = change_password_params[:user_id]
    email_old_password = change_password_params[:old_password]

    if token_param
      # Check for a non expired token, and then find its user
      token = Token.find_by_access_token(token_param)
      @new_password = change_password_params[:password]

      return nil if token.nil? || token.expired?

      return User.find_by_email(token.user_id)

    elsif email_param && email_old_password
      # Find a user and check that user exists and has the right password
      user = User.find_by_email(email_param)
      @new_password = change_password_params[:new_password]

      return nil if user.nil? || !user.valid_password?(email_old_password)

      return user
    else
      nil
    end
  end

end
