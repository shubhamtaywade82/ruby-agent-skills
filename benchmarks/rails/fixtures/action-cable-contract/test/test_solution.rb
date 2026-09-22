# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class NotificationsChannelTest < Minitest::Test
  def setup
    @channel=NotificationsChannel.new(connection:RealtimeConnection.new(user:7,tenant_id:10),resources:{1=>{id:1,tenant_id:10,version:2,state:"ready"},2=>{id:2,tenant_id:11,version:4,state:"ready"}})
  end
  def test_authorized_subscription
    r=@channel.subscribe(resource_id:1); assert_equal :subscribed,r[:status]; assert_equal "tenant:10:resource:1",r[:stream]
  end
  def test_cross_tenant_rejected = assert_equal(:rejected,@channel.subscribe(resource_id:2)[:status])
  def test_versioned_broadcast = assert_equal(1,@channel.broadcast(resource_id:1,notification:{type:"updated",message:"ok"})[:version])
  def test_reconcile = assert_equal("ready",@channel.reconcile(resource_id:1)[:state])
end
