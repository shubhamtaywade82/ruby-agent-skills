# frozen_string_literal: true

class AuthorizationContext
  attr_reader :actor, :tenant_id

  def initialize(actor:, tenant_id:)
    @actor = actor
    @tenant_id = tenant_id
  end

  # Read at decision time, never snapshotted: a membership revoked after a
  # job is enqueued or a channel subscribed must deny the next action.
  def revoked?
    membership = actor[:membership]
    !membership.nil? && membership[:active] != true
  end
end

class ReportPolicy
  def initialize(context)
    @context = context
  end

  def publish?(report)
    return false if @context.revoked?

    @context.actor[:role] == :publisher && report[:tenant_id] == @context.tenant_id
  end
end

# The single authoritative decision boundary: every entry point (direct
# call, job, channel) goes through ReportService#publish.
class ReportService
  def initialize(reports:)
    @reports = reports
  end

  def publish(id:, context:)
    report = tenant_scope(context).detect { |candidate| candidate[:id] == id }
    authorize!(report, context)
    report.merge(published: true)
  end

  private

  def tenant_scope(context)
    @reports.select { |candidate| candidate[:tenant_id] == context.tenant_id }
  end

  # Missing, cross-tenant, and forbidden are indistinguishable to the caller.
  def authorize!(report, context)
    raise "forbidden" unless report && ReportPolicy.new(context).publish?(report)

    true
  end
end

class PublishReportJob
  def initialize(service:, id:, context:)
    @service = service
    @id = id
    @context = context
  end

  # Re-authorizes on execution through the service; enqueue-time permission
  # is not trusted.
  def perform
    @service.publish(id: @id, context: @context)
  end
end

class ReportChannel
  def initialize(service:, context:)
    @service = service
    @context = context
  end

  def subscribe(id)
    @service.publish(id: id, context: @context)
  end
end
