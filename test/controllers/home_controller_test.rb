require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should contain login and sign up button" do
    get :index
    assert_response :success

    assert_select "a", href: "/user/sign_up", text: "Sign up"
    assert_select "a", href: "/user/sign_in", text: "Login"
  end
end
