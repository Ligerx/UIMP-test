class Uimp::AccountController < ApplicationController
  layout false

  def create_account
    new_user = User.new(create_account_params)

    if new_user.save
      # not sure how to redirect to additional login procedures
      # this site's simple login does not have this functionality
      render json: { redirect_url: root_url }, status: :created
    else
      render_error(Errors::LIST[:unable_to_create_account], :unprocessable_entity)
    end
  end


  def change_password
    user = find_user_from_token_or_login(params, request)
    (render_invalid_credentials_error and return) if user.nil? # This could be made to account for both types

    if user.update(password: params[:new_password])
      render json: {} and return
    else
      render_error(Error::LIST[:unable_to_update_password], :unprocessable_entity) and return
    end
  end


  def request_password_recovery
    render json: {instruction: "Go to the website's login page"}
  end


  def update_account
    ### Only takes an access token as authentication
    ### This will be strictly not for changing password
    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    if user.update(update_params)
      render json: {}
    else
      render_error(Errors::LIST[:unable_to_update_account_info])
    end
  end



  private
  def create_account_params
    params.permit(:email, :password, :password_confirmation, :client_id)
  end

  def update_params
    # right now email is the only other field from password
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
