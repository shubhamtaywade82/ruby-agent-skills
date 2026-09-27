# frozen_string_literal: true
module TenantConcern
  def tenant_id = raise(NotImplementedError)
end
class Component
  include TenantConcern
  attr_reader :config
  def initialize(tenant_id:,config:) = (@tenant_id,@config=tenant_id,config)
  def with_tenant(id) = raise(NotImplementedError)
  def emit(event,payload) = raise(NotImplementedError)
  def before_call = raise(NotImplementedError)
  def after_call = raise(NotImplementedError)
  def resolve_type(name)
    raise NotImplementedError
  end
end
class CurrentContext
  class << self
    attr_accessor :tenant_id
    def reset = raise(NotImplementedError)
  end
end
