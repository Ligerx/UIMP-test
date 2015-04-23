class Uimp::NotificationController < ApplicationController
  layout false

  def create_entry
    user = find_user(params)
    if user.nil?
      render json: { something: "RENDERERERERERE" } and return
    end

    new_notification = Notification.new(notification_params)

    if new_notification.save
      render json: {} and return
    else
      render json: {} and return
    end
  end

  def destroy_entry
    # ids are retrieved from the notification entries list

    # side note: remember to change the http codes for errors.
    user = find_user(params)

    if user.nil?
      render json: { something: "RENDERERERERERE" } and return
    end

    entry = Notification.find_by_user(user).find(params[:id])

    if entry.nil?
      render json: {} and return
    elsif entry.destroy
      render json: {} and return
    else
      render json: {} and return
    end
  end

  def show_entries
    # I'm assuming you can only see notifications for your own account
    user = find_user(params)
    if user.nil?
      render json: { something: "RENDER SOMETHING HERE" } and return
    end

    user_notifications = Notification.find_by_user(user).to_a

    json_info = {}
    user_notifications.each do |n|
      json_info[n.created_at] = { event: n.event, medium_type: n.medium_type, medium_information: n.medium_information }
    end

    render json: json_info and return
  end

  private
  def notification_params
    params.require(:notification).permit(:event, :medium_type, :medium_information)
  end

end
