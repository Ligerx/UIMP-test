require 'test_helper'

class Uimp::NotificationTest < ActionMailer::TestCase
  TEST_IP = '1.2.3.4'

  test 'default mail settings' do
    email = Uimp::Notification.notification_msg(users(:Alex), 'login_success', TEST_IP).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert_equal ['uimp.test@gmail.com'], email.from
    assert_equal [users(:Alex).email], email.to
    assert_equal ['Notification from UIMP'], email.subject
    assert email.body.to_s.include? '1.2.3.4'
  end
end
