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
    put :change_password, {access_token: tokens(:one).access_token, password: 'new_password'}
    assert_response :success

    user = users(:Alex)

    assert user.valid_password?('new_password'), "#{get_json_from @response.body}"
    assert_not user.valid_password? 'password'
  end

  test "should not change password given the wrong password" do
    put :change_password, {'user_id' => 'Bob@test.com', 'old_password' => 'wrong_password', 'new_password' => 'new_password'}
    assert_response :success

    user = users(:Bob)

    assert user.valid_password? 'password2'
    assert_not user.valid_password? 'wrong_password'
    assert_not user.valid_password? 'new_password'
  end

  test "should not change password given expired token" do
    put :change_password, {access_token: tokens(:three).access_token, password: 'new_password'}
    assert_response :success

    user = users(:Bob)

    assert user.valid_password? 'password2'
    assert_not user.valid_password? 'new_password'
  end


  test "should be able to create a new account" do
    account_params = {email: 'all_fields@gmail.com', password: 'password', password_confirmation: 'password'}
    post :create_account, account_params
    assert_response :success

    assert_includes User.all.to_a.map(&:email), "all_fields@gmail.com"


    ### Default behavior for strong parameters is to raise error when given extra fields
    ### You can disable this with an environment setting, but this behavior is not really super necessary
    ## ignore extraneous info? sort of like strong parameters
    # extraneous_fields = User.new(email: 'extraneous@gmail.com', password: 'password', password_confirmation: 'password', username: 'tim', active: false)
    # extraneous_fields.valid?
  end

  test "should not create account given bad incomplete info" do
    post :create_account, { password_confirmation: 'password' }
    assert_response :success #should these error pages be succeeding? I believe so?

    json = get_json_from @response.body
    assert_not_nil json['error_code']
    assert_not_nil json['error_description']
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
    put :update_account, {email: "new-username@gmail.com", access_token: tokens(:one).access_token}
    assert_response :success

    # assert_raises ActiveRecord::RecordNotFound, User.find_by_email("Alex@test.com")
    # assert_equal "new-username", User.find_by_email("new-username").email
    assert_equal "new-username@gmail.com", users(:Alex).email
    # flunk
  end

  test "should not update account info if given bad token" do
    put :update_account, {email: "new-username@gmail.com", access_token: tokens(:three).access_token}
    assert_response :success

    assert_not_equal "new-username@gmail.com", users(:Bob).email
  end

  ### Don't need to test this right now because User has no validations
  # test "should not update account info if info raises validation error" do
  #   flunk
  # end

end
