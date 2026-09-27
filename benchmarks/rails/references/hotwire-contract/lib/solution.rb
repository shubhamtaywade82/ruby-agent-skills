# frozen_string_literal: true

class HotwireContract
  def initialize(user:, authorized_ids:)
    @user = user
    @authorized_ids = authorized_ids
  end

  # Frame and stream ids are DOM identifiers, not authorization; both
  # responses re-check access server-side.
  def frame_response(id:, content:)
    return { status: 403 } unless authorized?(id)

    { status: 200, frame_id: dom_id(id), body: content }
  end

  def stream_response(id:, action:, content:)
    return { status: 403 } unless authorized?(id)

    { status: 200, action: action, target: dom_id(id), body: content }
  end

  def csrf_valid?(token, expected)
    !token.nil? && !expected.nil? && token == expected
  end

  # Private rendered HTML is cached per tenant.
  def cache_key(id:)
    "tenant:#{@user.fetch(:tenant_id)}:item:#{id}"
  end

  def controller_connect
    :connected
  end

  # Stimulus disconnect must release everything connect acquired.
  def controller_disconnect
    :disconnected
  end

  private

  def authorized?(id)
    @authorized_ids.include?(id)
  end

  def dom_id(id)
    "item_#{id}"
  end
end
