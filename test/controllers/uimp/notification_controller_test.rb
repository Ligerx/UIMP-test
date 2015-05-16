require 'test_helper'

class Uimp::NotificationControllerTest < ActionController::TestCase

  test "create entry with valid token" do
    count = Notification.count

    @request.headers['uimp-token'] = tokens(:one).access_token
    post :create_entry, { event: 'login_success', medium_type: 'email', medium_information: 'Alex@test.com' }
    assert_response :created

    assert_equal count+1, Notification.count

    user = users(:Alex)
    notif = Notification.where(user: user).last #should be the one created above
    assert_equal 'login_success', notif.event
    assert_equal 'email', notif.medium_type
    assert_equal 'Alex@test.com', notif.medium_information
  end

  test "not able to create entry with invalid inforamtion" do
    count = Notification.count

    @request.headers['uimp-token'] = tokens(:one).access_token
    post :create_entry, { event: 'not-an-event', medium_type: 'email', medium_information: 'Alex@test.com' }
    assert_response :unprocessable_entity
    assert_equal count, Notification.count

    post :create_entry, { event: 'login_success', medium_type: 'not-a-medium', medium_information: 'Alex@test.com' }
    assert_response :unprocessable_entity
    assert_equal count, Notification.count

    ### No validation on email yet
    # post :create_entry, { event: 'login_success', medium_type: 'email', medium_information: 'not-an-email' }
    # assert_response :success
    # assert_equal count, Notification.count
  end



  test "should destroy entry" do
    notif = notifications(:one)
    assert Notification.exists? notif

    @request.headers['uimp-token'] = tokens(:one).access_token
    delete :destroy_entry, { id: notif.id }
    assert_response :success

    assert_not Notification.exists? notif
  end

  test "should not destroy entry given non existant id" do
    notif = notifications(:one)

    @request.headers['uimp-token'] = tokens(:one).access_token
    
    # route :id without ( ) makes id mandatory
    # so, don't need to test missing id
    delete :destroy_entry, { id: 5000 }
    assert_response :not_found
    assert Notification.exists? notif
  end



  test "should show list of entries" do
    @request.headers['uimp-token'] = tokens(:one).access_token
    get :show_entries
    assert_response :success

    json = get_json_from @response.body
    list = json['notification_entry_list']

    # only show the 1 notification belonging to this token's user
    assert_equal 16, list.size

    notif_1_info = { 'id' => notifications(:one).id, 'event' => 'login_success', 'medium' => 'email', 'medium_information' => 'Alex@test.com' }
    assert list.include? notif_1_info
    # assert_equal notif_1_info, list[0], list.map {|hash| hash["id"]}
    # ^this test stopped working once I added more notifs in the fixtures.
    # Order wasn't guaranteed

    # notif_2_info = { 'id' => notifications(:two).id, 'event' => 'service_information', 'medium' => 'sms', 'medium_information' => '1112223333' }
    # assert_equal notif_2_info, list[1]
  end

end
