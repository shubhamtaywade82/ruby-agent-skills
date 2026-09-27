# frozen_string_literal: true

class MajorityElement
  # Boyer-Moore voting: O(n) time, O(1) space, then a verification pass
  # because the surviving candidate need not be a majority.
  def find(values)
    candidate = nil
    votes = 0
    values.each do |value|
      if votes.zero?
        candidate = value
        votes = 1
      elsif value == candidate
        votes += 1
      else
        votes -= 1
      end
    end
    return -1 if candidate.nil?

    occurrences = values.count(candidate)
    occurrences * 2 > values.length ? candidate : -1
  end
end
