# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class ActiveSupportContractTest < Minitest::Test
  def teardown; CurrentContext.reset; end
  def test_concern_and_configuration
    c=Component.new(tenant_id:7,config:{mode:"strict"})
    assert_equal 7,c.tenant_id; assert_equal "strict",c.config[:mode]
  end
  def test_context_is_explicit
    CurrentContext.tenant_id=7
    CurrentContext.reset
    assert_nil CurrentContext.tenant_id
  end
  def test_notifications_are_bounded
    p=Component.new(tenant_id:7,config:{}).emit("invoice.created",{resource_id:9,secret:"no"})
    assert_equal({resource_id:9},p[:payload])
  end
  def test_dynamic_types_are_allowlisted
    assert_equal Hash,Component.new(tenant_id:7,config:{}).resolve_type("Account")
    assert_raises(NameError){Component.new(tenant_id:7,config:{}).resolve_type("Object")}
  end
end
