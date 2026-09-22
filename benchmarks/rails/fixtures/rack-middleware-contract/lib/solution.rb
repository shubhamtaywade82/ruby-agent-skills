# frozen_string_literal: true
class RequestIdMiddleware
  def initialize(app:) = @app=app
  def call(env)
    request_id=env[:request_id] || "generated"
    return [429,{"content-type"=>"text/plain"},["rate limited"]] if env[:rate_limited]
    status,headers,body=@app.call(env.merge(request_id:request_id))
    [status,headers.merge("x-request-id"=>request_id),body]
  end
end
class DownstreamApp
  def call(env) = [200,{"content-type"=>"text/plain"},["ok:#{env[:request_id]}"]]
end
