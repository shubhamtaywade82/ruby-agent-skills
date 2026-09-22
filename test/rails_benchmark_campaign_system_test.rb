# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsBenchmarkCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_rails_campaign_is_registered_and_incremental
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    benchmark = manifest.fetch("benchmarks").fetch("rails")
    assert_equal "benchmarks/rails/fixtures.yml", benchmark.fetch("fixture_registry")
    assert_equal "benchmarks/rails/campaign.yml", benchmark.fetch("campaign_manifest")

    campaign = YAML.safe_load(File.read(File.join(ROOT, "benchmarks/rails/campaign.yml"), encoding: "UTF-8"))
    ids = Array(campaign.fetch("evaluations"))
    assert_equal ids.uniq, ids
    assert_operator ids.length, :>, 0

    public_ids = Dir[File.join(ROOT, "evals", "rails", "*.yml")].to_h do |path|
      data = YAML.safe_load(File.read(path, encoding: "UTF-8"))
      [data.fetch("id"), path]
    end
    assert((ids - public_ids.keys).empty?, "campaign contains unknown Rails evaluations")

    fixture_registry = YAML.safe_load(File.read(File.join(ROOT, "benchmarks/rails/fixtures.yml"), encoding: "UTF-8"))
    assert_equal ids.sort, fixture_registry.fetch("fixtures").keys.sort

    unbenchmarked = public_ids.keys - ids
    assert_operator unbenchmarked.length, :>, 0, "coverage expansion should remain incremental"
  end
end
