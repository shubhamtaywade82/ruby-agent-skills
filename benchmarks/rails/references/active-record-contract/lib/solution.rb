# frozen_string_literal: true

class Relation
  include Enumerable

  def initialize(rows, filters: [], ordering: nil)
    @rows = rows
    @filters = filters
    @ordering = ordering
  end

  def where(**conditions)
    self.class.new(@rows, filters: @filters + [conditions], ordering: @ordering)
  end

  def order(key)
    self.class.new(@rows, filters: @filters, ordering: key)
  end

  def pluck(*keys)
    to_a.map { |row| keys.length == 1 ? row.fetch(keys.first) : keys.map { |key| row.fetch(key) } }
  end

  def to_a
    rows = @filters.reduce(@rows) { |current, filter| current.select { |row| filter.all? { |k, v| row.fetch(k) == v } } }
    @ordering ? rows.sort_by { |row| row.fetch(@ordering) } : rows
  end

  def each(&block)
    to_a.each(&block)
  end
end

class OrderReport
  def initialize(rows)
    @rows = rows
  end

  def for_tenant(tenant_id)
    Relation.new(@rows).where(tenant_id: tenant_id)
  end

  def export_rows(batch_size: 2)
    each_batch(batch_size: batch_size).to_a
  end

  def each_batch(batch_size:)
    Enumerator.new do |yielder|
      @rows.each_slice(batch_size) { |batch| yielder << batch }
    end
  end
end

class OrderStateWriter
  attr_reader :events

  def initialize
    @events = []
  end

  def transition(order_id:, commit:)
    @pending = order_id if commit
  end

  def commit
    after_commit
  end

  def rollback
    @pending = nil
  end

  def after_commit
    @events << @pending if @pending
    @pending = nil
  end

  def destroy(order)
    order[:destroyed] = true
  end

  def delete(order)
    order[:deleted] = true
  end
end
