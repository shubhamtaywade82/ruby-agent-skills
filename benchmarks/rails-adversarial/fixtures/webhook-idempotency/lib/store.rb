# frozen_string_literal: true

# In-memory stand-in for the application's database adapter. Treat it as the
# database: do not change this file.

class UniqueViolation < StandardError; end

class Store
  def initialize
    @rows = Hash.new { |hash, table| hash[table] = [] }
    @unique_columns = Hash.new { |hash, table| hash[table] = [] }
    @next_id = 0
    @in_transaction = false
  end

  def add_unique_index(table, column)
    @unique_columns[table] |= [column]
  end

  # All writes inside the block commit together or not at all.
  def transaction
    return yield if @in_transaction

    snapshot = Marshal.load(Marshal.dump([@rows.to_a, @next_id]))
    @in_transaction = true
    yield
  rescue StandardError
    raise unless snapshot

    rows, @next_id = snapshot
    @rows = Hash.new { |hash, table| hash[table] = [] }.merge(rows.to_h)
    raise
  ensure
    @in_transaction = false if snapshot
  end

  def insert(table, attributes)
    @unique_columns[table].each do |column|
      if @rows[table].any? { |row| row[column] == attributes[column] }
        raise UniqueViolation, "#{table}.#{column} already has #{attributes[column].inspect}"
      end
    end

    @next_id += 1
    row = attributes.merge(id: @next_id)
    @rows[table] << row
    row.dup
  end

  def update(table, id, attributes)
    row = @rows[table].find { |candidate| candidate[:id] == id }
    raise KeyError, "#{table} #{id} not found" unless row

    row.merge!(attributes)
    row.dup
  end

  def find_by(table, conditions)
    @rows[table].find { |row| conditions.all? { |key, value| row[key] == value } }&.dup
  end

  def where(table, conditions)
    @rows[table].select { |row| conditions.all? { |key, value| row[key] == value } }.map(&:dup)
  end
end
