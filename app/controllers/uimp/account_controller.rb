class Uimp::AccountController < ApplicationController

  def change_password #CHANGE TO ALLOW TOKENS
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
    allowed_values = {email: params[:user_id], current_password: params[:old_password], password: params[:new_password]}
  end
end
