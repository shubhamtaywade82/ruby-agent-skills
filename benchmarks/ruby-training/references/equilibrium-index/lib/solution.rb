# frozen_string_literal: true

class EquilibriumIndex
  # O(n): track the running left sum and the remaining right sum (total minus
  # everything seen so far, minus the current element) as the array is walked
  # once.
  def find(values)
    total = values.sum
    left = 0
    values.each_with_index do |value, index|
      right = total - left - value
      return index if left == right

      left += value
    end
    nil
  end
end
