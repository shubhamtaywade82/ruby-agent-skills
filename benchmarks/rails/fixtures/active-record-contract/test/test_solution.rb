# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ActiveRecordContractTest < Minitest::Test
  def setup
    @rows = [
      { id: 1, tenant_id: 10, status: "open", name: "B" },
      { id: 2, tenant_id: 10, status: "paid", name: "A" },
      { id: 3, tenant_id: 11, status: "paid", name: "C" }
    ]
  end

  def test_relation_remains_composable
    relation = OrderReport.new(@rows).for_tenant(10).where(status: "paid").order(:name)
    assert_instance_of Relation, relation
    assert_equal [2], relation.pluck(:id)
  end

  def test_projection_returns_scalars
    assert_equal [[1, "B"], [2, "A"]], OrderReport.new(@rows).for_tenant(10).pluck(:id, :name)
  end

  def test_after_commit_does_not_fire_on_rollback
    writer = OrderStateWriter.new
    writer.transition(order_id: 42, commit: false)
    writer.rollback
    assert_empty writer.events

    writer.transition(order_id: 42, commit: true)
    writer.commit
    assert_equal [42], writer.events
  end

  def test_batch_iteration_is_bounded
    batches = OrderReport.new(@rows).each_batch(batch_size: 2).to_a
    assert_equal [[@rows[0], @rows[1]], [@rows[2]]], batches
  end

  def test_destroy_and_delete_remain_distinct
    order = {}
    writer = OrderStateWriter.new
    writer.destroy(order)
    assert order[:destroyed]

    other = {}
    writer.delete(other)
    assert other[:deleted]
  end
end
