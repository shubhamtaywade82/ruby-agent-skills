# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class RequestIdMiddlewareTest < Minitest::Test
  def setup; @middleware=RequestIdMiddleware.new(app:DownstreamApp.new); end
  def test_request_response_contract_and_correlation
    s,h,b=@middleware.call({})
    assert_equal 200,s; assert_equal "generated",h["x-request-id"]; assert_equal "ok:generated",b.first
  end
  def test_short_circuit_skips_downstream
    s,h,b=@middleware.call(rate_limited:true)
    assert_equal 429,s; assert_empty b; assert_equal "text/plain",h["content-type"]
  end
  def test_existing_id_is_preserved
    _,h,_=@middleware.call(request_id:"abc"); assert_equal "abc",h["x-request-id"]
  end
end
