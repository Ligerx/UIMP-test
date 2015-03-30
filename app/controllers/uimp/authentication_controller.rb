class Uimp::AuthenticationController < ApplicationController
  require 'date'

  def login
    if valid_credentials?(user_id: params[:user_id], password: params[:password])
      resource = User.find_by_email(params[:user_id])
      sign_in_and_redirect(resource) # can use sign_in_and_redirect, but this is not what the UIMP api specifies

      # resource.ensure_authentication_token!
    else
      render json: { error_code: 1, error_description: "Invalid login" }
    end
  end


  def create_token
    return unless valid_credentials?(user_id: params[:user_id], password: params[:password])

    # add new token to db
    # Based on the spec document, tokens taken user_id, but devise uses email by default
    # I'll just work with both standards right now
    token = Token.create(user_id: params[:user_id])

    render json: { access_token: token.access_token, expires_in: token.time_till_expiration }
  end


  def destroy_token
    # The access token should be passed in the header
    # The header token checks the validity of the action
    # The id passed is the token to be deleted
    unless valid_credentials? token: response.headers["uimp-token"]
      render json: { result: "failed", error_code: -4, error_description: "Invalid access token" } and return
    end

    header_token_user = Token.find_by_token(response.headers["uimp-token"])
    token_to_delete = Token.find(params[:id])

    if header_token_user.user_id != token_to_delete.user_id
      render json: { result: "failed", error_code: -3, error_description: "User mismatch" } and return
    elsif token_to_delete.nil?
      render json: { result: "failed", error_code: -2, error_description: "Token not found" } and return
    elsif token_to_delete.time_till_expiration < 0
      render json: { result: "failed", error_code: -1, error_description: "Already expired" } and return
    end

    # IF one of these things, then render
    # token_to_delete.destroy
    token_to_delete.update(expiration_date: DateTime.current)

    puts "\nDateTime.current" + DateTime.current.to_s

    render json: { result: "successfully deleted token" } and return
  end


  def active_tokens
    active_token_records = Token.valid.to_a
    access_tokens_array = active_token_records.map { |t| t.access_token }

    token_map = { access_token_list: access_tokens_array }
    render json: token_map and return
  end



  private
  def valid_credentials?(info={})
    (Token.valid_token? info[:token]) || (User.valid_login? info[:user_id], info[:password])
  end

end
