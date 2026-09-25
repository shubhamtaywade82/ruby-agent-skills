require "minitest/autorun"
require_relative "../lib/solution"

class UserTest < Minitest::Test
  def test_displays_name
    user = User.new(first_name: "Ada", last_name: "Lovelace")

    assert_equal "Ada Lovelace", user.display_name
  end
end
