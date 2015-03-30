require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "find_by_email should work" do
    assert_equal "Alex@test.com", User.find_by_email("Alex@test.com").email
  end

  test "should be valid login" do
    assert User.valid_login? "Alex@test.com", 'password'
    assert_not User.valid_login? "Alex@test.com", 'wrong-password'
  end

  test "should fail null login" do
    assert_not User.valid_login? nil, 'password'
    assert_not User.valid_login? 'Alex@test.com', nil
    assert_not User.valid_login? nil, nil
  end
end
