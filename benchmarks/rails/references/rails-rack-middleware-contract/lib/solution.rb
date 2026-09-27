# frozen_string_literal: true

class RequestIdMiddleware
  HEADER = "x-request-id"

  def initialize(app:)
    @app = app
  end

  def call(env)
    request_id = env[:request_id] || "generated"
    # Short-circuit: the downstream app is never called for a limited request.
    return [429, { "content-type" => "text/plain", HEADER => request_id }, []] if env[:rate_limited]

    status, headers, body = @app.call(env.merge(request_id: request_id))
    [status, headers.merge(HEADER => request_id), body]
  end
end

class DownstreamApp
  def call(env)
    [200, { "content-type" => "text/plain" }, ["ok:#{env[:request_id]}"]]
  end
end
