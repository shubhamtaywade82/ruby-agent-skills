# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ZeitwerkCheckCliTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_reports_generic_mode_without_rails
    Dir.mktmpdir do |root|
      stdout, status = Open3.capture2("ruby", File.join(ROOT, "bin/zeitwerk-check"), root)

      assert status.success?
      result = JSON.parse(stdout)
      assert_equal "generic", result.fetch("mode")
      assert_equal "skipped", result.fetch("checks").fetch("rails_zeitwerk_check").fetch("status")
    end
  end
end
