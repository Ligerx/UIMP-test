require 'test_helper'

class Uimp::AccountControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should change password" do
    # put :change_password, {'user_id' => 'Alex@test.com', 'old_password' => 'password', 'new_password' => 'new_password'}
    put :change_password, {user_id: 'Alex@test.com', old_password:'password', new_password:'new_password'}
    assert_response :success

    user = users(:Alex)
    # sign_in user

    assert user.valid_password?('new_password'), "#{get_json_from @response.body}"
    assert_not user.valid_password? 'password'
  end

  test "should NOT change password" do
    put :change_password, {'user_id' => 'Bob@test.com', 'old_password' => 'wrong_password', 'new_password' => 'new_password'}
    assert_response :success

    user = users(:Bob)
    sign_in user

    assert user.valid_password? 'password2'
    assert_not user.valid_password? 'wrong_password'
    assert_not user.valid_password? 'new_password'
  end
end
