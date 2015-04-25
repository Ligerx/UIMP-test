require 'test_helper'

class TokenTest < ActiveSupport::TestCase

  test "valid scope should work" do
    assert_equal 3, Token.valid.to_a.size
  end

  test "time till expiration should be default" do
    token = tokens(:one)
    assert_in_delta 36000, token.time_till_expiration, 1

    token2 = Token.create(user_id: 'test')
    assert_in_delta 36000, token2.time_till_expiration, 1

    assert_in_delta -600, tokens(:three).time_till_expiration, 1
  end

  test "time till expiration should be set to soon" do
    token = tokens(:one)
    token.update(expiration_date: 1.minute.from_now.to_datetime)

    assert_in_delta 60, token.time_till_expiration, 1
  end

  test "expired? should work" do
    assert tokens(:three).expired?

    tokens(:three).update(expiration_date: DateTime.current)
    assert tokens(:three).expired?

    tokens(:three).update(expiration_date: 1.second.ago.to_datetime)
    assert tokens(:three).expired?
  end

  test "not_expired should work" do
    assert tokens(:one).not_expired?
    assert tokens(:two).not_expired?
  end
end
