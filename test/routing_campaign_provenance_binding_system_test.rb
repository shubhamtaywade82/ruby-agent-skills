# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignProvenanceBindingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  RUNNER = File.join(ROOT, "bin", "routing-campaign-provenance-verify")

  def test_source_requires_preflight
    Dir.mktmpdir("routing-provenance") do |dir|
      _out, err, status = Open3.capture3(RbConfig.ruby, RUNNER, dir, chdir: ROOT)
      refute status.success?
      assert_includes err, "preflight.json not found"
    end
  end

  def test_accepts_current_repository_identity_from_preflight
    Dir.mktmpdir("routing-provenance") do |dir|
      sha = Open3.capture2("git", "-C", ROOT, "rev-parse", "HEAD").first.strip
      files = {
        "manifest_sha256" => "skill-manifest.yml",
        "campaign_manifest_sha256" => "router/ROUTING_CAMPAIGN.yml",
        "routing_cases_sha256" => "router/ROUTING_CASES.yml",
        "routing_contract_sha256" => "router/ROUTING.md"
      }
      repository = {"git_sha" => sha}
      files.each { |key, path| repository[key] = Digest::SHA256.file(File.join(ROOT, path)).hexdigest }
      preflight = {"repository" => repository}
      File.write(File.join(dir, "preflight.json"), JSON.pretty_generate(preflight))
      out, err, status = Open3.capture3(RbConfig.ruby, RUNNER, dir, chdir: ROOT)
      assert status.success?, "#{out}
#{err}"
      assert_includes out, "repository hashes: matched"
    end
  end

  def test_rejects_content_drift_even_when_git_sha_is_allowed
    Dir.mktmpdir("routing-provenance") do |dir|
      sha = Open3.capture2("git", "-C", ROOT, "rev-parse", "HEAD").first.strip
      repository = {
        "git_sha" => sha,
        "manifest_sha256" => "0" * 64,
        "campaign_manifest_sha256" => Digest::SHA256.file(File.join(ROOT, "router/ROUTING_CAMPAIGN.yml")).hexdigest,
        "routing_cases_sha256" => Digest::SHA256.file(File.join(ROOT, "router/ROUTING_CASES.yml")).hexdigest,
        "routing_contract_sha256" => Digest::SHA256.file(File.join(ROOT, "router/ROUTING.md")).hexdigest
      }
      File.write(File.join(dir, "preflight.json"), JSON.pretty_generate({"repository" => repository}))
      _out, err, status = Open3.capture3(RbConfig.ruby, RUNNER, dir, "--allow-repository-drift", chdir: ROOT)
      refute status.success?
      assert_includes err, "manifest_sha256 mismatch"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_provenance_binding_system_test.rb"
  end
end
