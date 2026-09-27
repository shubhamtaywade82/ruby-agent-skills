# frozen_string_literal: true

class RecursiveSelectionSorter
  def sort(values, start = 0)
    sorted = start.zero? ? values.dup : values
    return sorted if start >= sorted.length - 1

    minimum = start
    ((start + 1)...sorted.length).each do |candidate|
      minimum = candidate if sorted[candidate] < sorted[minimum]
    end
    sorted[start], sorted[minimum] = sorted[minimum], sorted[start]
    sort(sorted, start + 1)
  end
end
