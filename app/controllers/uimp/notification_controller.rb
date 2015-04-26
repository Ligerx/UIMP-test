class Uimp::NotificationController < ApplicationController
  layout false

  def create_entry
    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    new_notification = Notification.new(notification_params)
    new_notification.user = user

    if new_notification.save
      render json: {} and return
    else
      render_error(Errors::LIST[:unable_to_create_notification]) and return
    end
  end

  def destroy_entry
    # ids are retrieved from the notification entries list
    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    entry = Notification.where(user: user).find_by(id: params[:id])

    if entry.nil?
      render_error(Errors::LIST[:notification_not_found]) and return
    elsif entry.destroy
      render json: {} and return
    else
      render_error(Errors::LIST[:unable_to_delete_notification]) and return
    end
  end

  def show_entries
    # I'm assuming you can only see notifications for your own account
    user = find_user_by_request_token(request)
    (render_invalid_token_error and return) if user.nil?

    render json: entries_json(user) and return
  end


  private
  def notification_params
    params.permit(:event, :medium_type, :medium_information)
  end

  def entries_json(user)
    user_notifications = Notification.where(user_id: user.id).to_a

    json_info = { notification_entry_list: Array.new }
    user_notifications.each do |n|
      json_info[:notification_entry_list] << { id: n.id,
                                               event: n.event,
                                              'medium' => n.medium_type,
                                               medium_information: n.medium_information }
    end
    return json_info
  end

end
