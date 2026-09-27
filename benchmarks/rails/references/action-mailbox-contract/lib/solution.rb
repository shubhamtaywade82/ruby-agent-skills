# frozen_string_literal: true
class IngressAuthenticator
  def initialize(token) = @token=token
  def authenticate(value) = value==@token
end
class SupportMailbox
  def initialize(aliases:,eligible_senders:) = (@aliases,@eligible_senders,@processed=aliases,eligible_senders,{})
  def process(message)
    return {status: :rejected} unless @aliases.include?(message[:recipient]) && @eligible_senders.include?(message[:sender])
    id=message.fetch(:message_id)
    return {status: :duplicate} if @processed[id]
    @processed[id]=true
    {status: :processed,tenant_id:message.fetch(:tenant_id)}
  rescue KeyError
    {status: :quarantined}
  end
  def route(recipient) = @aliases.include?(recipient) ? :support : :backstop
  def retain_raw_message(message,retention_days:) = {message_id:message.fetch(:message_id),expires_at:Time.now+retention_days*86_400}
end
