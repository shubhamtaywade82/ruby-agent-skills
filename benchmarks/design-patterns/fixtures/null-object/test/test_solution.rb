require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_real_notifier
    notifier = EmailNotifier.new
    NotificationRouter.new(notifier: notifier).send("hello")
    assert_equal ["hello"], notifier.messages
  end

  def test_null_notifier
    assert_silent { NotificationRouter.new(notifier: NullNotifier.new).send("hello") }
  end
end
