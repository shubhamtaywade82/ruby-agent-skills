# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class HotwireContractTest < Minitest::Test
  def setup; @h=HotwireContract.new(user:{tenant_id:10},authorized_ids:[1]); end
  def test_frame_and_stream_preserve_authorization
    assert_equal 200,@h.frame_response(id:1,content:"ok")[:status]
    assert_equal 403,@h.stream_response(id:2,action:"replace",content:"x")[:status]
  end
  def test_stream_identity_is_stable
    assert_equal "item_1",@h.stream_response(id:1,action:"replace",content:"x")[:target]
  end
  def test_csrf_and_private_cache_identity
    assert @h.csrf_valid?("t","t"); refute @h.csrf_valid?(nil,"t")
    assert_includes @h.cache_key(id:1),"tenant:10"
  end
  def test_lifecycle_is_explicit
    assert_equal :connected,@h.controller_connect; assert_equal :disconnected,@h.controller_disconnect
  end
end
