class Uimp::AccountController < ApplicationController
  layout false

  def create_account
    new_user = User.new(create_account_params)

    if new_user.save
      # not sure how to redirect to additional login procedures
      # this site's simple login does not have this functionality
      render json: { redirect_url: root_url }
    else
      render_error(Errors::LIST[:unable_to_create_account])
    end
  end


  def change_password
    user = find_user_from_token_or_login(params, request)
    
    if user.nil?
      render json: {error_code: 2, error_description: "Invalid credentials"} and return
    end

    if user.update(password: params[:new_password])
      render json: {} and return
    else
      render json: {error_code: 3, error_description: "Error updating password"} and return
    end
  end


  def request_password_recovery
    render json: {instruction: "Go to the website's login page"}
  end


  def update_account
    ### Only takes an access token as authentication
    ### This will be strictly not for changing password
    # Do I also need to update token user_ids to match changes in email?
    user = find_user_by_request_token(request)
    if user.nil?
      render json: {error_code: 2, error_description: "Invalid credentials"} and return
    end

    if user.update(update_params)
      render json: {}
    else
      render json: {error_code: 4, error_description: "Error updating account info"}
    end
  end



  private
  def create_account_params
    params.permit(:email, :password, :password_confirmation)
  end

  def update_params
    # right now email is the only other field from password
    # authentication_params.permit(:email)
    params.permit(:email)
  end

  def find_user_from_token_or_login(params, request)
    edit_params_when_changing_password

    user = find_user_by_request_token(request)
    user = find_user_by_params_login(params) if user.nil?

    return user
  end

  def edit_params_when_changing_password
    if params[:password]
      # If given a token, the new password is named password
      # Change this to new_password
      params[:new_password] = params.delete(:password)
    else
      # if given login info, we have old_password and new_password
      # Change old_password to password
      params[:password] = params.delete(:old_password)
    end
  end

end
