# frozen_string_literal: true
module TenantConcern
  def tenant_id = @tenant_id
end
class Component
  include TenantConcern
  attr_reader :config
  def initialize(tenant_id:,config:) = (@tenant_id,@config=tenant_id,config)
  def with_tenant(id) = yield(id)
  def emit(event,payload) = {name:event,payload:payload.slice(:resource_id)}
  def before_call = :before
  def after_call = :after
  def resolve_type(name)
    allowed={"Invoice"=>String,"Account"=>Hash}
    allowed.fetch(name){raise NameError,"untrusted type"}
  end
end
class CurrentContext
  class << self
    attr_accessor :tenant_id
    def reset = self.tenant_id=nil
  end
end
