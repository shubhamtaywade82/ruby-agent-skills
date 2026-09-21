class VotingMachine
  def vote(voter:, candidate:)
    raise NotImplementedError
  end

  def leaderboard
    raise NotImplementedError
  end
end
