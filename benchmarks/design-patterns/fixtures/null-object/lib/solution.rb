class NullNotifier
  def notify(_message)
    raise NotImplementedError
  end
end

class EmailNotifier
  attr_reader :messages
  def initialize
    @messages = []
  end

  def notify(message)
    @messages << message
  end
end

class NotificationRouter
  def initialize(notifier:)
    @notifier = notifier
  end

  def send(message)
    @notifier.notify(message)
  end
end
