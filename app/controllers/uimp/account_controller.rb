class Uimp::AccountController < ApplicationController

  def change_password
    resource = User.find_by_email(params[:user_id]) # does this need strong parameters?
    return unless resource

    resource.update_with_password(change_password_params)
  end

  private
  def change_password_params
    # HOW DOES ENCRYPTION WORK?
    # IS IT PASSED ALREADY ENCRYPTED?
    params.require(:userid, :old_password, :new_password)

    # replace rename old_password to current_password to comply with Devise update_with_password
    params[:current_password] = params.delete :old_password
  end
end