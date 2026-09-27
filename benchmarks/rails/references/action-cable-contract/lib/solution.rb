# frozen_string_literal: true
class RealtimeConnection
  attr_reader :tenant_id
  def initialize(user:, tenant_id:) = (@user,@tenant_id=user,tenant_id)
  def authenticated? = !@user.nil?
end
class NotificationsChannel
  def initialize(connection:, resources:) = (@connection,@resources=connection,resources)
  def subscribe(resource_id:)
    r=@resources.fetch(resource_id)
    return {status: :rejected} unless r[:tenant_id]==@connection.tenant_id
    {status: :subscribed,stream:"tenant:#{@connection.tenant_id}:resource:#{resource_id}"}
  end
  def broadcast(resource_id:, notification:)
    r=@resources.fetch(resource_id)
    return unless r[:tenant_id]==@connection.tenant_id
    {version:1,resource_id:,type:notification.fetch(:type),message:notification.fetch(:message)}
  end
  def reconcile(resource_id:) = @resources.fetch(resource_id).slice(:id,:version,:state)
end
