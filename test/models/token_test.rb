require 'test_helper'

class TokenTest < ActiveSupport::TestCase

  test "valid scope should work" do
    assert_equal 2, Token.valid.to_a.size
  end

  test "valid token should work" do
    test_token = Token.create(user_id: 'test')

    assert Token.valid_token? test_token.access_token
  end

  test "no valid token if nil" do
    assert_not Token.valid_token? nil
  end
end
