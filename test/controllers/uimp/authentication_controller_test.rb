require 'test_helper'

class Uimp::AuthenticationControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # warden.authenticated? method from: http://www.quora.com/How-do-I-test-if-a-Devise-user-got-signed-in-from-a-controller-spec-or-test

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

    @request.headers["uimp-token"] = test_token1.access_token
    delete :destroy_token, id: test_token2.id

    json = get_json_from @response.body

    assert_equal "successfully deleted token", json['result'], "#{json['error_description']}"

    # IMPORTANT: ActiveRecord instances are not kept in sync with each other or the database.
    # Updating the token by passing its id into the delete_token action changes the db, but not this instance.
    # To make this instance reflect changes, you must call .reload on it
    assert test_token2.reload.expired?, "token time till expiration: #{test_token2.time_till_expiration}"
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
    assert controller.send(:valid_credentials?, {user_id: "Alex@test.com", password: "password"})

    assert_not controller.send(:valid_credentials?, {token: "aaaaaaaaaaaaaaa"})
    assert_not controller.send(:valid_credentials?, {user_id: "Alex@test.com", password: "wrong-password"})
  end

end
