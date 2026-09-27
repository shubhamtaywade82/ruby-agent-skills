class VotingMachine
  class InvalidVote < StandardError; end

  def initialize
    @ballots = {}
  end

  def vote(voter:, candidate:)
    raise InvalidVote, "voter and candidate are required" if blank?(voter) || blank?(candidate)
    raise InvalidVote, "#{voter} has already voted" if @ballots.key?(voter)

    @ballots[voter] = candidate
  end

  # Most votes first; ties broken by candidate name.
  def leaderboard
    @ballots.values.tally.sort_by { |candidate, votes| [-votes, candidate] }.map(&:first)
  end

  private

  def blank?(value)
    value.to_s.strip.empty?
  end
end
