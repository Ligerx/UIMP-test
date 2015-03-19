require 'test_helper'

class Uimp::InformationControllerTest < ActionController::TestCase
  # just testing presence of properties that are less likely to be changed

  test "should get service_information" do
    get :service_information
    assert_response :success

    json = get_json_from @response.body

    assert_equal "1.0", json["uimp_version"]
  end

  test "should get authentication_policy" do
    get :authentication_policy
    assert_response :success

    json = get_json_from @response.body

    assert_equal "password", json["scheme"]
  end

  test "should get required_user_information" do
    get :required_user_information
    assert_response :success

    json = get_json_from @response.body

    assert_equal ["client_id","email"], json["required_user_information"]
    assert_equal ["phone_number"], json["optional_user_information"]
  end

end
