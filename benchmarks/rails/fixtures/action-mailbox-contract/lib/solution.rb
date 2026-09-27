# frozen_string_literal: true
class IngressAuthenticator
  def initialize(token) = @token=token
  def authenticate(value) = raise(NotImplementedError)
end
class SupportMailbox
  def initialize(aliases:,eligible_senders:) = raise(NotImplementedError)
  def process(message)
    raise NotImplementedError
  end
  def route(recipient) = raise(NotImplementedError)
  def retain_raw_message(message,retention_days:) = raise(NotImplementedError)
end
