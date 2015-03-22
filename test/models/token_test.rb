require 'test_helper'

class TokenTest < ActiveSupport::TestCase

  test "valid scope should work" do
    assert_equal 2, Token.valid.to_a.size
  end
end
