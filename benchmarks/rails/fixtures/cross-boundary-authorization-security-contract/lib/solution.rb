# frozen_string_literal: true

class AuthorizationContext
  attr_reader :actor, :tenant_id

  def initialize(actor:, tenant_id:)
    @actor = actor
    @tenant_id = tenant_id
  end
end

class ReportPolicy
  def initialize(context)
    @context = context
  end

  def publish?(report)
    @context.actor[:role] == :publisher && report[:tenant_id] == @context.tenant_id
  end
end

class ReportService
  def initialize(reports:)
    @reports = reports
  end

  def publish(id:, context:)
    report = @reports.find { |candidate| candidate[:id] == id }
    authorize!(report, context)
    report.merge(published: true)
  end

  private

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
