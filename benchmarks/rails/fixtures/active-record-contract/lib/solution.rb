# frozen_string_literal: true

# Pre-refactor reporting and state-transition layer. Filters materialize to
# Arrays, ordering is implicit, exports load every record, the external-effect
# callback fires before commit, and destroy is an alias for bulk delete.
class Relation
  def initialize(rows)
    @rows = rows
  end

  def where(**conditions)
    @rows.select { |row| conditions.all? { |key, value| row.fetch(key) == value } }
  end
end

class OrderReport
  def initialize(rows)
    @rows = rows
  end

  def for_tenant(tenant_id)
    Relation.new(@rows).where(tenant_id: tenant_id)
  end

  def export_rows
    all_records = @rows.to_a
    all_records.map { |row| row }
  end
end

class OrderStateWriter
  attr_reader :events

  def initialize
    @events = []
  end

  def transition(order_id:, commit:)
    @events << order_id
  end

  def commit; end

  def rollback; end

  def delete(order)
    order[:deleted] = true
  end

  def destroy(order)
    delete(order)
  end
end
