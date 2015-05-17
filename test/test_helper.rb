require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/reporters'
# Minitest::Reporters.use!
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # include Devise::TestHelpers


  # Helper to decode the json response into a hash
  def get_json_from(response)
    # response should be a string, not an ActionDispatch::Response obj
    ActiveSupport::JSON.decode response
  end


  ### Mailer stuff
  TEST_IP = '1.2.3.4'

  # Mailer helpers generate generic api call email
  def general_response_msg(api, ip = TEST_IP)
    "#{api} was called (ip address: #{ip})\n"
  end

  # set the default ip in a test
  def set_test_ip(request, ip = TEST_IP)
    request.env['REMOTE_ADDR'] = ip
  end

  def mail_test_outline(api, message = general_response_msg(api), &block)
    size = ActionMailer::Base.deliveries.size

    set_test_ip(@request)
    block.call

    assert_equal size+1, ActionMailer::Base.deliveries.size, "Message probably wasn't sent"

    email = ActionMailer::Base.deliveries.last
    assert_equal message, email.body.to_s
  end

end
