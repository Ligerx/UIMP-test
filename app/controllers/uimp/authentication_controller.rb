class Uimp::AuthenticationController < ApplicationController
  layout false

  def login
    user = find_user_by_params_login(params)
    if user
      # event = (params[:client_id] && user.client_id == params[:client_id]) ? 
      #     'login_success' : 'login_success_without_client_id'
      # send_notification_to user, event
      check_client_id_and_send_message user, 'login_success', 'login_success_without_client_id'
      sign_in_and_redirect(user)
    else
      send_failure_message_and_render_error 'login_failure'
    end
  end


  def create_token
    user = find_user_by_params_login(params)
    if user
      # add new token to db
      # Based on the spec document, tokens taken user_id, but devise uses email by default
      # I'll just work with both standards right now
      check_client_id_and_send_message user,
              'get_access_token_success', 'get_access_token_success_without_client_id'

      token = Token.create(user_id: params[:user_id])
      render json: { access_token: token.access_token, expires_in: token.time_till_expiration },
             status: :created
    else
      send_failure_message_and_render_error 'get_access_token_failure'
    end
  end


  def destroy_token
    # The access token should be passed in the header
    # The header token checks the validity of the action
    # The id passed is the token to be deleted

    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    send_notification_to user, 'revoke_access_token'

    header_token_string = request.headers["uimp-token"]
    header_token = Token.find_by_access_token(header_token_string)
    token_to_delete = if params[:id]
                        Token.find_by_id(params[:id])
                      else
                        header_token
                      end

    if token_to_delete.nil?
      render_error Errors::LIST[:token_to_delete_not_found], :not_found and return
    elsif header_token.user_id != token_to_delete.user_id
      render_error Errors::LIST[:token_user_mismatch], :not_found and return
    end

    token_to_delete.update(expiration_date: DateTime.current)
    
    render json: { result: "successfully deleted token" } and return
  end


  def active_tokens
    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    send_notification_to user, 'get_access_token_list'
    render json: get_active_tokens_json(user) and return
  end


  private
  def get_active_tokens_json(user)
    tokens = Array.new

    active_token_records = Token.where(user_id: user.id).valid.to_a
    active_token_records.each do |t|
      tokens << {'id' => t.id, 'access_token' => t.access_token}
    end

    return { access_token_list: tokens }
  end

  def check_client_id_and_send_message(user, with, without)
    event = (params[:client_id] && user.client_id == params[:client_id]) ? 
    with : without
    send_notification_to user, event
  end

  def send_failure_message_and_render_error(event)
    user_no_pw = User.find_by(email: params[:user_id])

    send_notification_to(user_no_pw, event) if user_no_pw
    render_invalid_credentials_error(nil, user_no_pw, suppress: (user_no_pw ? true : false))
  end

end
