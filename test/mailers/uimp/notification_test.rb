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
    flunk 
  end

  test 'login failure' do
    flunk
  end


  ### access token events
  test 'get access token success' do
    flunk
  end

  test 'get access token success without client id' do
    flunk 
  end

  test 'get access token failure' do
    flunk
  end


  ### bad auth events
  test 'invalid access token' do
    flunk
  end

  test 'invalid login credentials' do
    flunk
  end


  ### other events
  test 'general api event responses' do
    flunk
  end

end
