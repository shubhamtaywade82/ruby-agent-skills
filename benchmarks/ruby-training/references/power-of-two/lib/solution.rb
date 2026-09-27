# frozen_string_literal: true

class PowerOfTwo
  # A positive power of two has exactly one set bit, so x & (x - 1) clears it.
  def check?(value)
    value.positive? && (value & (value - 1)).zero?
  end
end
