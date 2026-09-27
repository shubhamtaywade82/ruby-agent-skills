# frozen_string_literal: true
class RealtimeConnection
  attr_reader :tenant_id
  def initialize(user:, tenant_id:) = (@user,@tenant_id=user,tenant_id)
  def authenticated? = raise(NotImplementedError)
end
class NotificationsChannel
  def initialize(connection:, resources:) = (@connection,@resources=connection,resources)
  def subscribe(resource_id:)
    raise NotImplementedError
  end
  def broadcast(resource_id:, notification:)
    raise NotImplementedError
  end
  def reconcile(resource_id:) = raise(NotImplementedError)
end
