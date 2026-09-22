# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class SecurityMailerTest < Minitest::Test
  def setup; @mailer=SecurityMailer.new(users:{1=>{tenant_id:10,email:"owner@acme.test"},2=>{tenant_id:11,email:"other@test"}}); end
  def test_owner_is_recipient = assert_equal("owner@acme.test",@mailer.security_notice(user_id:1,tenant_id:10)[:to])
  def test_async_delivery = assert_equal("ActionMailer::MailDeliveryJob",@mailer.deliver_later(user_id:1,tenant_id:10)[:job])
  def test_cross_tenant_is_rejected = assert_nil(@mailer.deliver_later(user_id:2,tenant_id:10))
end
