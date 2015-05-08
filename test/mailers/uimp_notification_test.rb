require 'test_helper'

class UimpNotificationTest < ActionMailer::TestCase
  test 'mailer' do
    email = Usermailer.notification_msg(user, ':login', 'login', success: false)
    assert_not ActionMailer::Base.deliveries.empty?

    # assert_equal email.to: 50
  end

end
