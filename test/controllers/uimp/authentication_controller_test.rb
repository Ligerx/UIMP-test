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
    assert_response :unauthorized

    json = get_json_from @response.body
    # assert_equal "Invalid login", json['error_description']
    assert_equal Errors::LIST[:invalid_credentials][1], json['error_description']
    assert_not warden.authenticated?(:user)
  end



  test "should create new token" do
    post :create_token, {user_id: 'Alex@test.com', password:'password'}
    assert_response :created

    json = get_json_from @response.body

    assert_equal 128, json['access_token'].length
    assert_in_delta 36000, json['expires_in'], 1
  end

  test "should not create new token" do
    post :create_token, {user_id: 'Alex@test.com', password:'wrong-password'}
    assert_response :unauthorized

    json = get_json_from @response.body

    assert_nil json['access_token']
    assert_equal Errors::LIST[:invalid_credentials][1], json['error_description']
  end



  test "should delete self token if not given an id" do
    test_token = tokens(:one)

    @request.headers["uimp-token"] = test_token.access_token
    delete :destroy_token
    assert_response :success

    json = get_json_from @response.body

    assert_equal "successfully deleted token", json['result'], "#{json['error_description']}"

    # See message in "should destroy token 2 given token 1" test
    assert test_token.reload.expired?, "token time till expiration: #{test_token.time_till_expiration}"
  end

  test "should destroy token 2 given token 1" do
    user = users(:Alex).id
    test_token1 = Token.create(user_id: user)
    test_token2 = Token.create(user_id: user)

    @request.headers["uimp-token"] = test_token1.access_token
    delete :destroy_token, id: test_token2.id
    assert_response :success

    json = get_json_from @response.body

    assert_equal "successfully deleted token", json['result'], "#{json['error_description']}"

    # IMPORTANT: ActiveRecord instances are not kept in sync with each other or the database.
    # Updating the token by passing its id into the delete_token action changes the db, but not this instance.
    # To make this instance reflect changes, you must call .reload on it
    assert test_token2.reload.expired?, "token time till expiration: #{test_token2.time_till_expiration}"
  end

  test "should not destroy tokens" do
    @request.headers["uimp-token"] = "not-a-token"
    delete :destroy_token, id: tokens(:one).id
    assert_response :unauthorized
    json = get_json_from @response.body
    assert_equal Errors::LIST[:invalid_token][1], json['error_description']


    @request.headers["uimp-token"] = tokens(:one).access_token
    delete :destroy_token, id: -1 #Token shouldn't exist
    assert_response :not_found
    json = get_json_from @response.body
    assert_equal Errors::LIST[:token_to_delete_not_found][1], json['error_description']


    @request.headers["uimp-token"] = tokens(:one).access_token
    delete :destroy_token, id: tokens(:two).id #Token should have different users
    assert_response :not_found # Not found because it shouldn't exist from the user's perspective
    json = get_json_from @response.body
    assert_equal Errors::LIST[:token_user_mismatch][1], json['error_description']


    @request.headers["uimp-token"] = tokens(:three).access_token
    delete :destroy_token, id: tokens(:three).id #Token should be expired
    assert_response :unauthorized
    json = get_json_from @response.body
    assert_equal Errors::LIST[:invalid_token][1], json['error_description']
  end



  test "should show active tokens" do
    # flunk # reformat the output to be correct json
    @request.headers["uimp-token"] = tokens(:two).access_token
    get :active_tokens
    assert_response :success

    json = get_json_from @response.body

    # Tokens for this particular user
    # 2 active tokens, 1 inactive token which is not included
    assert_equal 2, json['access_token_list'].size

    json['access_token_list'].each do |t|
      assert_not_nil t['id']
      assert_equal 128, t['access_token'].length
    end
  end


  ####################
  ### Mailer tests

  # login: login x3
  # token: token x3
  # destroy_token: invalid token, self
  # active tokens: invalid token, self

  test 'login success w/ client_id message' do
    mail_test_outline 'login_success', 
                      "Your account was accessed (ip address: 1.2.3.4)\n" do
      post :login, {user_id: 'Alex@test.com', password: 'password', client_id: '1234'}
    end
  end

  test 'login success w/o client_id message' do
    mail_test_outline 'login_success_without_client_id', 
                      "Your account was accessed by manually typing your login info (ip address: 1.2.3.4)\n" do
      post :login, {user_id: 'Alex@test.com', password: 'password'}
    end
  end

  test 'login failure message' do
    mail_test_outline 'login_failure', 
                      "Someone unsuccessfully tried to access your account (ip address: 1.2.3.4)\n" do
      post :login, {user_id: 'Alex@test.com', password: 'wrong-password'}
    end
  end

  test "can't send login failure message if username not found" do
    size = ActionMailer::Base.deliveries.size
    post :login, {user_id: 'not-an-email@test.com', password: 'password'}
    
    assert_equal size, ActionMailer::Base.deliveries.size, "Shouldn't send a message if user isn't found"
  end


  test 'get access token success message' do
    flunk
  end

  test 'get access token success w/ client_id message' do
    flunk
  end

  test 'get access token failure message' do
    flunk
  end


  test 'destroy token sends message' do
    mail_test_outline 'revoke_access_token' do
      @request.headers["uimp-token"] = tokens(:one).access_token
      delete :destroy_token
    end
  end

  test 'active tokens list sends message' do
    mail_test_outline 'get_access_token_list' do
      @request.headers["uimp-token"] = tokens(:one).access_token
      get :active_tokens
    end
  end

end
