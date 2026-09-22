# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class CrossBoundaryAuthorizationContractTest < Minitest::Test
  def setup
    @reports = [
      { id: 1, tenant_id: 10, owner_id: 7, published: false },
      { id: 2, tenant_id: 11, owner_id: 7, published: false }
    ]
    @service = ReportService.new(reports: @reports)
  end

  def test_direct_service_invocation_is_authorized
    context = AuthorizationContext.new(
      actor: { id: 7, role: :publisher },
      tenant_id: 10
    )

    assert @service.publish(id: 1, context: context)[:published]
    assert_raises(RuntimeError) { @service.publish(id: 2, context: context) }
  end

  def test_job_reauthorizes_after_membership_revocation
    membership = { active: true }
    context = AuthorizationContext.new(
      actor: { id: 7, role: :publisher, membership: membership },
      tenant_id: 10
    )
    job = PublishReportJob.new(service: @service, id: 1, context: context)

    membership[:active] = false

    assert_raises(RuntimeError) { job.perform }
  end

  def test_channel_rechecks_current_context
    context = AuthorizationContext.new(
      actor: { id: 7, role: :publisher },
      tenant_id: 10
    )
    channel = ReportChannel.new(service: @service, context: context)

    assert channel.subscribe(1)
  end

  def test_replayed_cross_tenant_operation_is_rejected
    context = AuthorizationContext.new(
      actor: { id: 7, role: :publisher },
      tenant_id: 10
    )

    assert_raises(RuntimeError) { @service.publish(id: 2, context: context) }
  end
end
