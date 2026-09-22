# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class DocumentAttachmentTest < Minitest::Test
  def setup
    @service=DocumentAttachment.new(account:{id:1,tenant_id:10},allowed_types:["application/pdf"])
  end
  def test_authorized_attachment_and_access
    @service.attach(file:{key:"k1",content_type:"application/pdf",bytes:100},tenant_id:10)
    assert_equal "k1",@service.serve(tenant_id:10)[:key]
  end
  def test_cross_tenant_and_invalid_upload
    assert_raises(RuntimeError){@service.serve(tenant_id:11)}
    assert_raises(RuntimeError){@service.attach(file:{key:"k2",content_type:"text/plain",bytes:100},tenant_id:10)}
  end
  def test_cleanup_is_async
    assert_equal "ActiveStorage::PurgeJob",@service.purge_later[:job]
  end
end
