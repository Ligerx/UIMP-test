class Notification < ActiveRecord::Base
  DEFINED_EVENTS =  %w[always invalid_client_token login_success login_success_without_client_id login_failure]
  API_EVENTS = %w[
                  service_information
                  requested_user_information
                  authentication_policy
                  login
                  get_access_token
                  revoke_access_token
                  get_access_token_list
                  create_account
                  change_password
                  request_password_recovery
                  update_account_information
                  create_notification_entry
                  delete_notification_entry
                  get_notification_entry_list
                 ]
  
  EVENTS = DEFINED_EVENTS + API_EVENTS


  belongs_to :user

  validate :user_exists
  validates_inclusion_of :event, in: EVENTS
  validates_inclusion_of :medium_type, in: %w[email sms]
  # validate the medium_information (phone/sms) later if necessary

  private
  def user_exists
    if user.nil?
      errors.add(:notification, "not connected to a user")
    elsif !(User.exists?(user) && User.find(user).valid?)
      errors.add(:notification, "user does not exist in the system")
    end
  end

end
