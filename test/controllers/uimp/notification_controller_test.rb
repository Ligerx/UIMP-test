require 'test_helper'

class Uimp::NotificationControllerTest < ActionController::TestCase

  test "create entry with valid token" do
    count = Notification.count

    @request.headers['uimp-token'] = tokens(:one).access_token
    post :create_entry, { event: 'login_success', medium_type: 'email', medium_information: 'Alex@test.com' }
    assert_response :success

    assert_equal count+1, Notification.count
  end

  test "not able to create entry with invalid token" do
    flunk
  end

  test "not able to create entry with invalid inforamtion" do
    flunk
  end



  test "should destroy entry" do
    flunk
  end

  test "should not destroy entry given invalid token" do
    flunk
  end

  test "should not destroy entry given non existant id" do
    flunk
  end



  test "should show list of entries" do
    flunk
  end

end
