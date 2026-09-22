# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class AuthorizationContractTest < Minitest::Test
  def setup
    @documents = [
      { id: 1, tenant_id: 10, owner_id: 7, title: "A" },
      { id: 2, tenant_id: 11, owner_id: 7, title: "B" },
      { id: 3, tenant_id: 10, owner_id: 8, title: "C" }
    ]
    @service = DocumentService.new(documents: @documents)
  end

  def test_direct_resource_lookup_cannot_cross_tenants
    actor = { id: 7, tenant_id: 10, role: :member }

    error = assert_raises(RuntimeError) { @service.fetch(id: 2, actor: actor) }

    assert_equal "forbidden", error.message
  end

  def test_collection_scope_excludes_other_tenants_before_enumeration
    actor = { id: 7, tenant_id: 10, role: :member }

    assert_equal [1], @service.list(actor: actor).map { |document| document[:id] }
  end

  def test_owner_in_another_tenant_does_not_gain_access
    actor = { id: 7, tenant_id: 11, role: :member }

    error = assert_raises(RuntimeError) { @service.fetch(id: 1, actor: actor) }

    assert_equal "forbidden", error.message
  end

  def test_admin_is_still_tenant_scoped
    actor = { id: 99, tenant_id: 10, role: :admin }

    assert_equal [1, 3], @service.list(actor: actor).map { |document| document[:id] }
  end
end
