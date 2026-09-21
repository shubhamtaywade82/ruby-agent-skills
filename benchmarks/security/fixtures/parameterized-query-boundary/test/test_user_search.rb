# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/user_search"

class FakeRelation
  attr_reader :arguments

  def where(*arguments)
    @arguments = arguments
    self
  end
end

class UserSearchTest < Minitest::Test
  def test_parameterized_where
    relation = FakeRelation.new
    UserSearch.call("alice", relation: relation)
    assert_equal ["name ILIKE ?", "%alice%"], relation.arguments
  end
end
