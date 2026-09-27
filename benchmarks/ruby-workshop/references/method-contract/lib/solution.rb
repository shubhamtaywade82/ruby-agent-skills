class NotificationFormatter
  SUPPORTED_CHANNELS = %i[email sms].freeze

  # Returns "channel: recipient" for supported channels; anything else is a
  # caller error.
  def format(recipient:, channel:)
    raise ArgumentError, "unsupported channel: #{channel.inspect}" unless SUPPORTED_CHANNELS.include?(channel)

    "#{channel}: #{recipient}"
  end
end
