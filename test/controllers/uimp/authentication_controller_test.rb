require 'test_helper'

class Uimp::AuthenticationControllerTest < ActionController::TestCase
  include Devise::TestHelpers


  test "should log in a user" do
    assert false
  end


  test "should create new token" do
    post :create_token, {user_id: 'Alex@test.com', password:'password'}
    assert_response :success

    json = get_json_from @response.body

    assert_equal 128, json['access_token'].length
    assert_in_delta 36000, json['expires_in'], 1
  end


  test "should destroy token" do
    assert false
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

end
