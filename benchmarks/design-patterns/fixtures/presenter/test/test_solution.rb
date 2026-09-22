require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_display_name
    user = User.new("Sam", "Taylor", :premium)
    presenter = UserPresenter.new(user)
    assert_equal "Sam Taylor", presenter.display_name
    assert_equal "Premium", presenter.membership_label
  end
end
