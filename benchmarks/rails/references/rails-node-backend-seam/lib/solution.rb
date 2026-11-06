# frozen_string_literal: true

# Reference implementation: the Rails side of the Rails <-> Node backend seam,
# modeled as a PORO. Renders RFC 9457 problem+json, echoes X-Request-ID,
# configures the cross-origin session cookie, and declares the write
# authority. The Node side belongs to node-agent-skills / node-ruby-integration.

module Seam
  class RefundsController
    # Shared-Postgres seam: Rails writes refunds; the Node side reads only.
    WRITE_AUTHORITY = :rails

    PROBLEM_TYPE = "https://example.com/errors/validation"
    PROBLEM_NOT_FOUND = "https://example.com/errors/not-found"

    def initialize(orders:, refunds:, clock: -> { Time.now })
      @orders = orders
      @refunds = refunds
      @clock = clock
    end

    def create_refund(order_id:, attrs:, request_id:, origin: :same_origin)
      order = @orders[order_id]
      return problem(:not_found, PROBLEM_NOT_FOUND, "Order not found.", []) unless order

      refund = build_refund(order, attrs)
      return problem(:unprocessable_entity, PROBLEM_TYPE, "Validation failed.", refund[:errors]) unless refund[:valid]

      @refunds[refund[:id]] = refund.slice(:id, :order_id, :amount_cents, :reason, :created_at)
      {
        status: :created,
        body: @refunds[refund[:id]],
        headers: response_headers(request_id)
      }
    end

    # Cookie attributes the Node BFF needs when it runs on another origin:
    # SameSite=None (with Secure) or the browser silently drops the cookie.
    def session_cookie
      { same_site: :none, secure: true, httponly: true }
    end

    private

    def build_refund(order, attrs)
      errors = []
      errors << { field: :amount_cents, message: "must be greater than zero" } unless attrs[:amount_cents].to_i.positive?
      errors << { field: :reason, message: "is required" } if attrs[:reason].to_s.strip.empty?
      errors << { field: :order_id, message: "order is not refundable" } unless order[:status] == :placed
      return { valid: false, errors: errors } if errors.any?

      {
        valid: true,
        id: "ref_#{order[:id]}_#{@refunds.length + 1}",
        order_id: order[:id],
        amount_cents: attrs[:amount_cents],
        reason: attrs[:reason],
        created_at: @clock.call
      }
    end

    def problem(status, type, detail, errors)
      {
        status: status,
        body: {
          type: type,
          title: status == :not_found ? "Not Found" : "Validation failed",
          status: status == :not_found ? 404 : 422,
          detail: detail,
          errors: errors
        },
        headers: response_headers(nil)
      }
    end

    def response_headers(request_id)
      headers = { "Content-Type" => "application/problem+json" }
      # The correlation ID propagates back across the language boundary.
      headers["X-Request-ID"] = request_id if request_id
      headers
    end
  end
end
