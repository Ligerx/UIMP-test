require 'test_helper'

class Uimp::InformationControllerTest < ActionController::TestCase
  test "should get service_information" do
    get :service_information
    assert_response :success
  end

  test "should get authentication_policy" do
    get :authentication_policy
    assert_response :success
  end

  test "should get required_user_information" do
    get :required_user_information
    assert_response :success
  end

end
