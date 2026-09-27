# frozen_string_literal: true

class Counter
  def initialize
    @value = 0
    @mutex = Mutex.new
  end

  def increment
    @mutex.synchronize { @value += 1 }
  end

  def value
    @mutex.synchronize { @value }
  end
end
