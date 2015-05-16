require 'test_helper'

class Uimp::NotificationTest < ActionMailer::TestCase
  TEST_IP = '1.2.3.4'

  test 'default mail settings' do
    # .deliver changed to .deliver_now + .deliver_later in Rails 4.2 I believe
    email = Uimp::Notification.notification_msg(users(:Alex), 'login_success', TEST_IP).deliver
    assert_not ActionMailer::Base.deliveries.empty?

    assert_equal ['uimp.test@gmail.com'], email.from
    assert_equal [users(:Alex).email], email.to
    assert_equal 'Notification from UIMP', email.subject
    assert email.body.include? '1.2.3.4'
  end


  ### login events
  test 'login success' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'login_success', TEST_IP).deliver
    assert_equal read_fixture('login_success').join, email.body.to_s
  end

  test 'login success without client id' do
    # Bob doesn't have a client id. In this mailer test it really doesn't matter though.
    email = Uimp::Notification.notification_msg(users(:Bob), 'login_success_without_client_id', TEST_IP).deliver
    assert_equal read_fixture('login_success_without_client_id').join, email.body.to_s
  end

  test 'login failure' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'login_failure', TEST_IP).deliver
    assert_equal read_fixture('login_failure').join, email.body.to_s
  end


  ### access token events
  test 'get access token success' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'get_access_token_success', TEST_IP).deliver
    assert_equal read_fixture('get_access_token_success').join, email.body.to_s
  end

  test 'get access token success without client id' do
    email = Uimp::Notification.notification_msg(users(:Bob), 'get_access_token_success_without_client_id', TEST_IP).deliver
    assert_equal read_fixture('get_access_token_success_without_client_id').join, email.body.to_s
  end

  test 'get access token failure' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'get_access_token_failure', TEST_IP).deliver
    assert_equal read_fixture('get_access_token_failure').join, email.body.to_s
  end


  ### bad auth events
  test 'invalid access token' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'invalid_access_token', TEST_IP).deliver
    assert_equal read_fixture('invalid_access_token').join, email.body.to_s
  end

  test 'invalid login credentials' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'invalid_login_credentials', TEST_IP).deliver
    assert_equal read_fixture('invalid_login_credentials').join, email.body.to_s
  end


  ### other events
  test 'general api event responses' do
    email1 = Uimp::Notification.notification_msg(users(:Alex), 'change_password', TEST_IP).deliver
    assert_equal read_fixture('general_error_1').join, email1.body.to_s

    email2 = Uimp::Notification.notification_msg(users(:Alex), 'get_notification_entry_list', TEST_IP).deliver
    assert_equal read_fixture('general_error_2').join, email2.body.to_s
  end

  test 'event that is not defined raises an error' do
    assert_raise(RuntimeError) {Uimp::Notification.notification_msg(users(:Alex), 'not-an-error', TEST_IP).deliver}
  end

end
