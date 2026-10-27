# frozen_string_literal: true

# Rails side of the Rails <-> Node backend seam, modeled as a PORO so the
# contract can be verified without booting Rails. The Node side belongs to
# the companion node-agent-skills pack and is intentionally absent.

module Seam
  class RefundsController
    def initialize(orders:, refunds:, clock: -> { Time.now })
      @orders = orders
      @refunds = refunds
      @clock = clock
    end

    def create_refund(order_id:, attrs:, request_id:, origin: :same_origin)
      order = @orders[order_id]
      return not_found(order_id) unless order

      refund = build_refund(order, attrs)
      unless refund[:valid]
        return render_unprocessable_entity(refund[:errors])
      end

      @refunds[refund[:id]] = refund.slice(:id, :order_id, :amount_cents, :reason, :created_at)
      {
        status: :created,
        body: @refunds[refund[:id]],
        headers: { "Content-Type" => "application/json" }
      }
    end

    # Cookie attributes the Node BFF needs when it runs on another origin.
    def session_cookie
      { httponly: true, secure: true }
    end

    private

    def build_refund(order, attrs)
      errors = []
      errors << [:amount_cents, "must be greater than zero"] unless attrs[:amount_cents].to_i.positive?
      errors << [:reason, "is required"] if attrs[:reason].to_s.strip.empty?
      errors << [:order_id, "order is not refundable"] unless order[:status] == :placed
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

    def render_unprocessable_entity(errors)
      {
        status: :unprocessable_entity,
        body: { errors: errors.to_h },
        headers: { "Content-Type" => "application/json" }
      }
    end

    def not_found(order_id)
      {
        status: :not_found,
        body: { error: "Unknown order #{order_id}" },
        headers: { "Content-Type" => "application/json" }
      }
    end
  end
end
