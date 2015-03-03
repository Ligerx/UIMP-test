class Uimp::AuthenticationController < ApplicationController

  def login
    resource = User.find_by_email(params[:user_id]) # does this need strong parameters?
    return unless resource

    #when do we deal with encryption?
    if resource.valid_password?(params[:password])
      #sign_in(resource)
      sign_in_and_redirect(resource) # can use sign_in_and_redirect, but this is not what the UIMP api specifies

      # resource.ensure_authentication_token!
    end

  end



  # private
  # def login_params
  #   # HOW DOES ENCRYPTION WORK?
  #   # IS IT PASSED ALREADY ENCRYPTED?
  #   params.require(:email, :password)
  # end
end
