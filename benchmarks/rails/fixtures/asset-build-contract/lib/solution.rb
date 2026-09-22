# frozen_string_literal: true
class AssetBuild
  def initialize(strategy:,lockfile:) = (@strategy,@lockfile=strategy,lockfile)
  def strategy_selection = @strategy
  def build(source_digest:)
    raise "missing lockfile" if @lockfile.nil? || @lockfile.empty?
    {artifact:"assets-#{source_digest}",reproducible:true}
  end
  def precompile(source_digest:) = build(source_digest:)
  def cache_key(source_digest:) = "#{@strategy}:#{@lockfile}:#{source_digest}"
  def dependency_contract = {runtime:"ruby-rails",lockfile:@lockfile}
end
