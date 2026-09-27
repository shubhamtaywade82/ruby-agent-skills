# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"

module RubyAgentSkills
  # Runs a fixture's original test file against an agent's workspace.
  #
  # The workspace copy of the test file is agent-editable, so grading with it
  # lets an agent pass by weakening assertions. This copies the workspace to a
  # scratch directory, restores the fixture's test file at its original
  # relative path (so `require_relative "../lib/..."` still resolves), and
  # runs it there. The agent's own workspace is never modified.
  module FixtureTestRun
    Result = Struct.new(:stdout, :stderr, :status, :test_modified, keyword_init: true) do
      def success?
        status.success?
      end

      def output
        stdout + stderr
      end
    end

    def self.call(workspace:, fixture_root:, test_file:)
      pristine = File.join(fixture_root, test_file)
      raise ArgumentError, "fixture test file not found: #{pristine}" unless File.file?(pristine)

      submitted = File.join(workspace, test_file)
      modified = !File.file?(submitted) || File.binread(submitted) != File.binread(pristine)

      Dir.mktmpdir("ruby-agent-fixture-test-") do |scratch|
        FileUtils.cp_r(File.join(workspace, "."), scratch)
        target = File.join(scratch, test_file)
        FileUtils.mkdir_p(File.dirname(target))
        FileUtils.cp(pristine, target)

        stdout, stderr, status = Open3.capture3("ruby", "-Ilib", test_file, chdir: scratch)
        Result.new(stdout: stdout, stderr: stderr, status: status, test_modified: modified)
      end
    end
  end
end
