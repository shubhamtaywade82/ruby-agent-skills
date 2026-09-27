# frozen_string_literal: true
class AssetBuild
  def initialize(strategy:,lockfile:) = (@strategy,@lockfile=strategy,lockfile)
  def strategy_selection = raise(NotImplementedError)
  def build(source_digest:)
    raise NotImplementedError
  end
  def precompile(source_digest:) = raise(NotImplementedError)
  def cache_key(source_digest:) = raise(NotImplementedError)
  def dependency_contract = raise(NotImplementedError)
end
