require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "find_by_email should work" do
    assert_equal "Alex@test.com", User.find_by_email("Alex@test.com").email
  end
end
