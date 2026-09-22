require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_deactivate
    user = User.new
    assert_same user, User::Deactivate.new(user).call
    assert_equal false, user.active
  end
end
