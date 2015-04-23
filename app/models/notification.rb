class Notification < ActiveRecord::Base
  belongs_to :user

  # does not include the <UIMP API name> events right now
  validates_inclusion_of :event, in: %w[always invalid_client_token login_success login_success_without_client_id login_failure]
  validates_inclusion_of :medium_type, in: %w[email sms]
end
