# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class SupportMailboxTest < Minitest::Test
  def setup; @mailbox=SupportMailbox.new(aliases:["help@acme.test"],eligible_senders:["owner@acme.test"]); end
  def test_duplicate_is_deterministic
    m={recipient:"help@acme.test",sender:"owner@acme.test",message_id:"m1",tenant_id:7}
    assert_equal :processed,@mailbox.process(m)[:status]
    assert_equal :duplicate,@mailbox.process(m)[:status]
  end
  def test_spoofed_sender_rejected
    assert_equal :rejected,@mailbox.process(recipient:"help@acme.test",sender:"bad@test",message_id:"m2",tenant_id:7)[:status]
  end
  def test_poison_and_routing
    assert_equal :quarantined,@mailbox.process(recipient:"help@acme.test",sender:"owner@acme.test",message_id:"m3")[:status]
    assert_equal :backstop,@mailbox.route("other@test")
  end
end
