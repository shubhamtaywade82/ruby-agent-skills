# frozen_string_literal: true

class BubbleSorter
  # Repeatedly walk the array, swapping adjacent out-of-order elements, until
  # a full pass makes no swap.
  def sort(values)
    sorted = values.dup
    loop do
      swapped = false
      (0...(sorted.length - 1)).each do |index|
        next unless sorted[index] > sorted[index + 1]

        sorted[index], sorted[index + 1] = sorted[index + 1], sorted[index]
        swapped = true
      end
      break unless swapped
    end
    sorted
  end
end
