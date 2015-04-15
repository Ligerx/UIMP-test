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
    flunk
  end

  test "should update account info" do
    # ignore invalid info
    flunk
  end

  test "should not update account info if given bad token" do
    flunk
  end

  test "should not update account info if info raises validation error" do
    flunk
  end

end
