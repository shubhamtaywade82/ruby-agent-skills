# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class AssociationsContractTest < Minitest::Test
  def setup; @account=Account.new(id:1,tenant_id:10); @project=Object.new; end
  def test_through_membership_keeps_targets
    m=Membership.new(account:@account,project:@project,state:"active")
    assert_same @account,m.account; assert_same @project,m.project
  end
  def test_polymorphic_types_are_bounded
    assert_raises(ArgumentError){AttachmentTarget.new(type:"User")}
  end
  def test_loading_and_autosave_are_narrow
    service=AssociationContract.new(account:@account); service.autosave!(@project)
    assert_equal [@project],service.each_recent
  end
end
