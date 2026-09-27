# frozen_string_literal: true

class TripletSum
  # Sort in place, fix one element, and close in on the remaining range with
  # two pointers: O(n^2) time and O(1) auxiliary space, as the assessment
  # requires. The input array is reordered.
  def find(values, target)
    sorted = values.sort!
    (0...(sorted.length - 2)).each do |fixed|
      left = fixed + 1
      right = sorted.length - 1
      while left < right
        sum = sorted[fixed] + sorted[left] + sorted[right]
        return [sorted[fixed], sorted[left], sorted[right]] if sum == target

        sum < target ? left += 1 : right -= 1
      end
    end
    nil
  end
end
