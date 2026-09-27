require "minitest/autorun"
require_relative "../lib/solution"

class VotingMachineTest < Minitest::Test
  def setup
    @machine = VotingMachine.new
  end

  def test_leaderboard_orders_by_votes_then_name
    @machine.vote(voter: "Alice", candidate: "Sam")
    @machine.vote(voter: "Bob", candidate: "Pat")
    @machine.vote(voter: "Cara", candidate: "Sam")
    @machine.vote(voter: "Dan", candidate: "Lee")
    assert_equal %w[Sam Lee Pat], @machine.leaderboard
  end

  def test_voter_cannot_vote_twice
    @machine.vote(voter: "Alice", candidate: "Sam")
    assert_raises(VotingMachine::InvalidVote) { @machine.vote(voter: "Alice", candidate: "Pat") }
  end

  def test_blank_names_are_rejected
    assert_raises(VotingMachine::InvalidVote) { @machine.vote(voter: " ", candidate: "Sam") }
    assert_raises(VotingMachine::InvalidVote) { @machine.vote(voter: "Alice", candidate: "") }
  end
end
