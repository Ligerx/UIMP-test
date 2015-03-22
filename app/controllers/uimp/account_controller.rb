class Uimp::AccountController < ApplicationController

  def change_password
    resource = User.find_by_email(params[:user_id]) # does this need strong parameters?
    return unless resource
    if !resource
      render json: {error_code: 1, error_description: "Could not find user"}
    end

    begin
      resource.update_with_password(change_password_params)
    rescue ForbiddenAttributesError
      render json: {error_code: 2, error_description: "Problem changing password with given info"}
    end
    
    render json: {}
  end

  private
  def change_password_params
    # HOW DOES ENCRYPTION WORK?
    # IS IT PASSED ALREADY ENCRYPTED?
    params.require(:user_id)
    params.require(:old_password)
    params.require(:new_password)

    # Choose one of these. If allowing the default action and controller causes problems, use second.
    params.permit(:action, :controller, :current_password)
    # params.except(:action, :controller)

    # replace rename old_password to current_password to comply with Devise update_with_password
    # params[:current_password] = params.delete :old_password
    # params[:current_password] = params[:old_password]
    
    allowed_values = {email: params[:user_id], current_password: params[:old_password], password: params[:new_password]}
  end
end
