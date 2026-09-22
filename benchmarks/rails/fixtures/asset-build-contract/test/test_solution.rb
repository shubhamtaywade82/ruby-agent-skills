# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class AssetBuildTest < Minitest::Test
  def setup; @build=AssetBuild.new(strategy: :importmap,lockfile:"abc123"); end
  def test_existing_strategy_is_reused
    assert_equal :importmap,@build.strategy_selection
  end
  def test_build_and_precompile_are_reproducible
    a=@build.build(source_digest:"src1"); b=@build.precompile(source_digest:"src1")
    assert_equal a,b; assert a[:reproducible]
  end
  def test_cache_identity_contains_inputs
    assert_includes @build.cache_key(source_digest:"src1"),"abc123"
  end
end
