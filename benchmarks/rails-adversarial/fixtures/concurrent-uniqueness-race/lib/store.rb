# frozen_string_literal: true

# In-memory stand-in for the application's database adapter. Treat it as the
# database: do not change this file.

class UniqueViolation < StandardError; end

class Store
  def initialize
    @rows = Hash.new { |hash, table| hash[table] = [] }
    @unique_columns = Hash.new { |hash, table| hash[table] = [] }
    @next_id = 0
    @lock = Mutex.new
  end

  def add_unique_index(table, column)
    @lock.synchronize { @unique_columns[table] |= [column] }
  end

  def insert(table, attributes)
    @lock.synchronize do
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
  end

  def find_by(table, conditions)
    @lock.synchronize do
      @rows[table].find { |row| conditions.all? { |key, value| row[key] == value } }&.dup
    end
  end

  def count(table)
    @lock.synchronize { @rows[table].length }
  end
end
