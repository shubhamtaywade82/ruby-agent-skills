# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "json"
require "tmpdir"
require "fileutils"

class StackMinimalityToolSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  COMMAND = File.join(ROOT, "bin", "stack-minimality")

  def test_help_lists_supported_commands
    stdout, stderr, status = Open3.capture3(COMMAND, "help", chdir: ROOT)

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "stack-minimality"
    assert_includes stdout, "debt"
    assert_includes stdout, "evidence"
  end

  def test_debt_reports_markers_without_scanning_build_output
    Dir.mktmpdir("stack-minimality") do |dir|
      File.write(File.join(dir, "app.rb"), "# stack-minimality: sequential path; revisit when volume exceeds 1m rows\n")
      FileUtils.mkdir_p(File.join(dir, "node_modules"))
      File.write(File.join(dir, "node_modules", "ignored.js"), "// stack-minimality: should not be reported\n")

      stdout, stderr, status = Open3.capture3(COMMAND, "debt", dir, chdir: ROOT)

      assert status.success?, "#{stdout}\n#{stderr}"
      assert_includes stdout, "1 marker"
      assert_includes stdout, "app.rb:1"
      refute_includes stdout, "ignored.js"
    end
  end

  def test_evidence_reads_a_real_git_diff
    Dir.mktmpdir("stack-minimality-git") do |dir|
      system("git", "init", "-q", dir)
      File.write(File.join(dir, "README.md"), "one\n")
      system("git", "-C", dir, "add", "README.md")
      system("git", "-C", dir, "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-q", "-m", "init")
      File.write(File.join(dir, "README.md"), "one\ntwo\n")

      stdout, stderr, status = Open3.capture3(COMMAND, "evidence", dir, chdir: ROOT)

      assert status.success?, "#{stdout}\n#{stderr}"
      data = JSON.parse(stdout)
      assert_equal 1, data.fetch("changed_files")
      assert_equal 1, data.fetch("added_lines")
      assert_equal 0, data.fetch("deleted_lines")
      assert_equal 1, data.fetch("file_delta")
    end
  end
end
