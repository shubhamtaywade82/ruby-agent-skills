# frozen_string_literal: true

class Counter
  def initialize
    @value = 0
  end

  # Read-modify-write on shared state; the yield stands in for any work
  # (logging, I/O) between the read and the write.
  def increment
    current = @value
    Thread.pass
    @value = current + 1
  end

  def value
    @value
  end
end
