require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "should allow defined events and all API events" do
    EVENTS = %w[
                login_success
                login_success_without_client_id
                login_failure

                get_access_token_success
                get_access_token_success_without_client_id
                get_access_token_failure

                invalid_access_token
                invalid_login_credentials

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

    notif = Notification.new( user_id: users(:Alex).id,
                              event: 'login_success',
                              medium_type: 'email',
                              medium_information: 'Alex@test.com'
                            )
    assert notif.valid?

    EVENTS.each do |event|
      notif.event = event
      assert notif.valid?, event
    end

    notif.event = 'not-an-event'
    assert_not notif.valid?
  end

  test "should require a user" do
    notif = Notification.new(event: 'always', medium_type: 'email', medium_information: 'Alex@test.com')
    assert_not notif.valid?

    user = User.new(email: 'user@test.com', password: 'password', password_confirmation: 'password')
    notif.user = user # user may be valid but is not in the db
    assert_not notif.valid?
  end

  test "should take valid medium_type" do
    user = User.create(email: 'user@test.com', password: 'password', password_confirmation: 'password')
    notif = Notification.new(user: user, event: 'login_success', medium_information: 'Alex@test.com')
    
    notif.medium_type = 'email'
    assert notif.valid?

    notif.medium_type = 'sms'
    assert notif.valid?

    user.delete
  end

  # test "should take valid medium_information" do
  #   flunk
  # end


end
