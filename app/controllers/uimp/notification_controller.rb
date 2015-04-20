class Uimp::NotificationController < ApplicationController
  layout false

  def create_enty
    user = find_user(params)
    
  end

  def destroy_entry
    user = find_user(params)

  end

  def show_entries
    # I'm assuming you can only see notifications for your own account
    user = find_user(params)
    if user.nil?
      render json: { something: "RENDER SOMETHING HERE" }
    end

    user_notifications = Notification.find_by_user(user).to_a

    json_info = {}
    user_notifications.each do |n|
      json_info[n.created_at] = { event: n.event, medium_type: n.medium_type, medium_information: n.medium_information }
    end

    render json: json_info
  end

end
