require 'test_helper'

class Uimp::AuthenticationControllerTest < ActionController::TestCase
  include Devise::TestHelpers


  test "should log in a user" do
    user_id = 'Alex@test.com'
    post :login, {user_id: user_id, password: 'password'}
    assert_response :redirect

    # assert_not_nil User.current_user
    assert warden.authenticated?(:user)
  end

  test "should NOT log in a user" do
    user_id = 'Alex@test.com'
    post :login, {user_id: user_id, password: 'wrong-password'}
    assert_response :success

    json = get_json_from @response.body
    assert_equal "Invalid login", json['error_description']
    assert_not warden.authenticated?(:user)
  end


  test "should create new token" do
    post :create_token, {user_id: 'Alex@test.com', password:'password'}
    assert_response :success

    json = get_json_from @response.body

    assert_equal 128, json['access_token'].length
    assert_in_delta 36000, json['expires_in'], 1
  end


  test "should destroy token 2 given token 1" do
    test_token1 = Token.create(user_id: 'test')
    test_token2 = Token.create(user_id: 'test')

    @request.headers['uimp-token'] = test_token1.access_token
    delete :destroy_token, {id: test_token2.id}

    # puts "\nTime till expiration"+test_token2.time_till_expiration.to_s
    # puts "\nDateTime.current" + DateTime.current.to_s

    json = get_json_from @response.body

    assert_equal "successfully deleted token", json['result'], "#{json['error_description']}"
    assert test_token2.expired?, "#{test_token2.time_till_expiration}"
    #assert false
  end


  test "should show active tokens" do
    get :active_tokens
    assert_response :success

    json = get_json_from @response.body

    assert_equal 2, json['access_token_list'].size

    json['access_token_list'].each do |t|
      assert_equal 128, t.length
    end
  end

  test "should show valid_credentials works" do
    controller = Uimp::AuthenticationController.new
    assert controller.send(:valid_credentials?, {token: tokens(:one).access_token})
    # assert AuthenticationController.new.send(valid_credentials?, "Alex@test.com", "password")
  end

end
