# frozen_string_literal: true

class SelectionSorter
  # Iterative: for each position, select the minimum of the unsorted suffix.
  def sort(values)
    sorted = values.dup
    sorted.each_index do |position|
      minimum = position
      ((position + 1)...sorted.length).each do |candidate|
        minimum = candidate if sorted[candidate] < sorted[minimum]
      end
      sorted[position], sorted[minimum] = sorted[minimum], sorted[position]
    end
    sorted
  end

  # Recursive: place the minimum at `start`, then recurse on the remaining suffix.
  def recursive_sort(values, start = 0)
    sorted = start.zero? ? values.dup : values
    return sorted if start >= sorted.length - 1

    minimum = start
    ((start + 1)...sorted.length).each do |candidate|
      minimum = candidate if sorted[candidate] < sorted[minimum]
    end
    sorted[start], sorted[minimum] = sorted[minimum], sorted[start]
    recursive_sort(sorted, start + 1)
  end
end
