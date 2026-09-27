require "minitest/autorun"
require_relative "../lib/solution"

class NotificationFormatterTest < Minitest::Test
  def test_supported_channels
    formatter = NotificationFormatter.new
    assert_equal "email: Sam", formatter.format(recipient: "Sam", channel: :email)
    assert_equal "sms: Sam", formatter.format(recipient: "Sam", channel: :sms)
  end

  def test_unsupported_channel_raises
    assert_raises(ArgumentError) { NotificationFormatter.new.format(recipient: "Sam", channel: :push) }
  end

  def test_keywords_are_required
    assert_raises(ArgumentError) { NotificationFormatter.new.format(recipient: "Sam") }
  end
end
