# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RailsNodeBackendSeamTest < Minitest::Test
  def setup
    @now = Time.new(2026, 1, 1, 12, 0, 0)
    @clock = -> { @now }
    @orders = {
      "ord_1" => { id: "ord_1", status: :placed, total_cents: 12_000 },
      "ord_2" => { id: "ord_2", status: :shipped, total_cents: 4_500 }
    }
    @refunds = {}
    @controller = Seam::RefundsController.new(orders: @orders, refunds: @refunds, clock: @clock)
  end

  def test_successful_refund_renders_created_and_echoes_the_request_id
    result = @controller.create_refund(
      order_id: "ord_1",
      attrs: { amount_cents: 2_500, reason: "damaged item" },
      request_id: "req-abc-123",
      origin: :cross_origin
    )

    assert_equal :created, result[:status]
    assert_equal "ord_1", result[:body][:order_id]
    assert_equal 2_500, result[:body][:amount_cents]
    # The correlation ID crosses the language boundary in both directions.
    assert_equal "req-abc-123", result[:headers]["X-Request-ID"]
  end

  def test_validation_failure_renders_problem_json_not_rails_default_errors
    result = @controller.create_refund(
      order_id: "ord_1",
      attrs: { amount_cents: 0, reason: "  " },
      request_id: "req-abc-123",
      origin: :cross_origin
    )

    assert_equal :unprocessable_entity, result[:status]
    body = result[:body]
    # RFC 9457 problem+json contract the Node consumer maps 1:1.
    assert_equal 422, body[:status]
    refute_nil body[:type]
    refute_nil body[:title]
    fields = body[:errors].map { |error| error[:field] }
    assert_includes fields, :amount_cents
    assert_includes fields, :reason
    # Not the Rails default { errors: { field: [...] } } mapping.
    refute body[:errors].is_a?(Hash)
  end

  def test_unknown_order_renders_problem_json_without_leaking_internals
    result = @controller.create_refund(
      order_id: "ord_missing",
      attrs: { amount_cents: 100, reason: "partial" },
      request_id: "req-abc-123",
      origin: :cross_origin
    )

    assert_equal :not_found, result[:status]
    assert_equal 404, result[:body][:status]
    result[:body].each_value { |value| refute value.to_s.include?("backtrace") }
  end

  def test_cross_origin_session_cookie_uses_same_site_none
    cookie = @controller.session_cookie

    # Without SameSite=None the browser silently drops the cookie on the
    # cross-origin Node BFF call and auth fails mysteriously.
    assert_equal :none, cookie[:same_site]
    assert_equal true, cookie[:secure]
    assert_equal true, cookie[:httponly]
  end

  def test_rails_is_the_declared_write_authority_for_refunds
    # Shared-Postgres seam: one side writes, the other reads.
    assert_equal :rails, Seam::RefundsController::WRITE_AUTHORITY
  end
end
