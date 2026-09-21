class NotificationFormatter
  def format(recipient:, channel:)
    raise NotImplementedError
  end
end
