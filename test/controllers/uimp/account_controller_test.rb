require 'test_helper'

class Uimp::AccountControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should change password with user_id and old password" do
    put :change_password, {user_id: 'Alex@test.com', old_password:'password', new_password:'new_password'}
    assert_response :success

    user = users(:Alex)

    assert user.valid_password?('new_password'), "#{get_json_from @response.body}"
    assert_not user.valid_password? 'password'
  end

  test "should change password with token" do
    @request.headers['uimp-token'] = tokens(:one).access_token
    put :change_password, {password: 'new_password'}
    assert_response :success

    user = users(:Alex)

    assert user.valid_password?('new_password'), "#{get_json_from @response.body}"
    assert_not user.valid_password? 'password'
  end

  test "should not change password given the wrong password" do
    put :change_password, {'user_id' => 'Bob@test.com', 'old_password' => 'wrong_password', 'new_password' => 'new_password'}
    assert_response :unauthorized

    user = users(:Bob)

    assert user.valid_password? 'password2'
    assert_not user.valid_password? 'wrong_password'
    assert_not user.valid_password? 'new_password'
  end

  test "should not change password given expired token" do
    put :change_password, {access_token: tokens(:three).access_token, password: 'new_password'}
    assert_response :unauthorized

    user = users(:Bob)

    assert user.valid_password? 'password2'
    assert_not user.valid_password? 'new_password'
  end


  test "should be able to create a new account" do
    account_params = {email: 'all_fields@gmail.com', password: 'password', password_confirmation: 'password'}
    post :create_account, account_params
    assert_response :created

    assert_includes User.all.to_a.map(&:email), "all_fields@gmail.com"
  end

  test "should not create account given bad incomplete info" do
    post :create_account, { password_confirmation: 'password' }
    assert_response :unprocessable_entity

    json = get_json_from @response.body
    assert_equal Errors::LIST[:unable_to_create_account][0], json['error_code']
    assert_equal Errors::LIST[:unable_to_create_account][1], json['error_description']
  end


  test "should give instructions on recovering password" do
    # this is currently a post
    # should this become a get?

    # also, where what do I do about the instructions?
    # Are they supposed to be stored in the same place as the rest of the errors?
    post :request_password_recovery
    assert_response :success

    json = get_json_from @response.body
    assert_not_nil json['instruction']
  end


  test "should update account info given a token" do
    @request.headers['uimp-token'] = tokens(:one).access_token
    put :update_account, {email: "new-username@gmail.com"}
    assert_response :success

    # assert_raises ActiveRecord::RecordNotFound, User.find_by_email("Alex@test.com")
    # assert_equal "new-username", User.find_by_email("new-username").email
    assert_equal "new-username@gmail.com", users(:Alex).email
    # flunk
  end

  test "should not update account info if given bad token" do
    put :update_account, {email: "new-username@gmail.com", access_token: tokens(:three).access_token}
    assert_response :unauthorized

    assert_not_equal "new-username@gmail.com", users(:Bob).email
  end

  ### Don't need to test this right now because User has no validations
  # test "should not update account info if info raises validation error" do
  #   flunk
  # end




  ####################
  ### Mailer tests

  # create_account: NONE (this one doesn't really make sense to exist)
  # change_password: invalid cred/token, self
  # request_password_recovery: self
  # update account: invalid token, self

  test 'change password sends message' do
    mail_test_outline 'change_password' do
      put :change_password, {user_id: 'Alex@test.com', old_password:'password', new_password:'new_password'}
    end
  end

  # password recovery instructions request is independent of user
  # test 'request password sends a message' do
  # end

  test 'update account sends a message' do
    mail_test_outline 'update_account_information' do
      @request.headers['uimp-token'] = tokens(:one).access_token
      put :update_account, {email: "new-username@gmail.com"}
    end
  end

end
