# frozen_string_literal: true

class SmallestMissing
  # Sorted, unique, non-negative input: values[i] == i holds exactly up to the
  # first gap, so binary search finds it in O(log n).
  def find(values)
    low = 0
    high = values.length
    while low < high
      mid = (low + high) >> 1
      if values[mid] == mid
        low = mid + 1
      else
        high = mid
      end
    end
    low
  end
end
