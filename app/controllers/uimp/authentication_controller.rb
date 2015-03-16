class Uimp::AuthenticationController < ApplicationController
  require 'DateTime'

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


  def create_token
    resource = User.find_by_email(params[:user_id])

    # render json error messages here instead
    return unless resource
    return unless resource.valid_password?(params[:password])

    # add new token to db
    token = Token.create(user_id: params[:user_id])

    render json: { access_token: token.access_token, expires_in: token.time_till_expiration }
  end

  def destroy_token
    # should this method expire a token, or actually delete it?
    # how does this interact with active/inactive tokens?

    # documentation says that the token should be passed as the id
    token_list = Token.where(access_token: params[id]).to_a
    
    if token_list.size > 1
      # error, shouldn't happen
      # should return json with error
      render json: { result: "failed", error_code: -1, error_description: "Multiple tokens???" } and return
    elsif token_list.size == 0
      # token does not exist
      # should return json with error
      render json: { result: "failed", error_code: -2, error_description: "Access token does not exist" } and return
    end
        
    # found the token 
    token = token_list[0]

    # IF one of these things, then render
    # token.destroy
    # token.update(expiration_date: DateTime.current)
    render json: { result: "successfully deleted token" } and return
  end

  def active_tokens
    active_tokens_list = Token.valid.to_a
    access_tokens = active_tokens_list.map { |t| t.access_token }

    render json: access_tokens and return
  end


  # private
  # def login_params
  #   # HOW DOES ENCRYPTION WORK?
  #   # IS IT PASSED ALREADY ENCRYPTED?
  #   params.require(:email, :password)
  # end
end
