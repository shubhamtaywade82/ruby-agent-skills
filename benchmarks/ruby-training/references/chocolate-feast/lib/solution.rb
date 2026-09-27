# frozen_string_literal: true

class ChocolateFeast
  # Wrappers from free chocolates are exchanged again whenever the threshold
  # is reached. A threshold below 2 would yield chocolates forever.
  def call(money, cost, wrappers)
    raise ArgumentError, "cost must be positive" unless cost.positive?
    raise ArgumentError, "wrapper threshold must be at least 2" if wrappers < 2

    eaten = money / cost
    held = eaten
    while held >= wrappers
      free = held / wrappers
      eaten += free
      held = (held - (free * wrappers)) + free
    end
    eaten
  end
end
