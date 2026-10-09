# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

module HeadlessAdapterFixture
  ROOT = File.expand_path("..", __dir__)
  DECISION = {
    "primary_skill" => "rails-authentication",
    "secondary_skills" => ["rails-security-engineering"],
    "reason" => "password recovery owns authentication"
  }.freeze
  ADAPTERS = {
    cursor: %w[coding-agent-cursor routing-agent-cursor CURSOR_AGENT_MODEL
               CURSOR_AGENT_BIN],
    antigravity: %w[coding-agent-antigravity routing-agent-antigravity AGY_MODEL AGY_BIN],
    opencode: %w[coding-agent-opencode routing-agent-opencode OPENCODE_MODEL OPENCODE_BIN]
  }.freeze

  def run_adapter(dir, provider, kind, model: "test-model", stdout: nil)
    coding, routing, model_env, bin_env = ADAPTERS.fetch(provider)
    script = kind == :coding ? coding : routing
    env = environment(dir, model_env, bin_env, script, model)
    env["FAKE_STDOUT"] = stdout if stdout
    Open3.capture3(env, RbConfig.ruby, File.join(ROOT, "bin", script))
  end

  def environment(dir, model_env, bin_env, script, model)
    cli_env(dir, model_env, bin_env, script, model).merge(routing_env(dir))
  end

  def cli_env(dir, model_env, bin_env, script, model)
    {
      bin_env => fake_cli(dir),
      model_env => model,
      "FAKE_ARGV" => File.join(dir, "argv.json"),
      "FAKE_STDIN" => File.join(dir, "stdin.txt"),
      "FAKE_STDOUT" => fake_stdout(script),
      "RUBY_AGENT_WORKSPACE" => dir
    }
  end

  def routing_env(dir)
    {
      "RUBY_AGENT_ROUTING_PROTOCOL_VERSION" => "1",
      "RUBY_AGENT_ROUTING_CASE_ID" => "case-1",
      "RUBY_AGENT_ROUTING_PROMPT_FILE" => write_file(dir, "prompt.txt", "Reset a password.\n"),
      "RUBY_AGENT_ROUTING_RESULT_FILE" => File.join(dir, "result.json"),
      "RUBY_AGENT_ROUTING_MANIFEST_FILE" => manifest_file(dir),
      "RUBY_AGENT_ROUTING_ROUTER_FILE" => write_file(dir, "router.md", "routing contract\n"),
      "RUBY_AGENT_CONTEXT_FILE" => write_file(dir, "context.md", "implement the task")
    }
  end

  def manifest_file(dir)
    body = "skills:\n  rails-authentication: {}\n  rails-security-engineering: {}\n"
    write_file(dir, "manifest.yml", body)
  end

  def recorded(dir)
    argv = JSON.parse(File.read(File.join(dir, "argv.json"), encoding: "UTF-8"))
    stdin = File.read(File.join(dir, "stdin.txt"), encoding: "UTF-8")
    [argv, stdin]
  end

  def capture(provider, kind, stdout: nil)
    Dir.mktmpdir do |dir|
      out, err, status = run_adapter(dir, provider, kind, stdout: stdout)
      yield dir, out, err, status
    end
  end

  def fake_stdout(script)
    decision = JSON.generate(DECISION)
    return cursor_stdout(DECISION) if script.end_with?("cursor")
    return antigravity_stdout if script.end_with?("antigravity")

    "#{JSON.generate('type' => 'text', 'part' => { 'text' => decision })}\n"
  end

  def cursor_stdout(decision)
    JSON.generate("type" => "result", "is_error" => false, "result" => JSON.generate(decision))
  end

  def antigravity_stdout
    JSON.generate("status" => "SUCCESS", "structured_output" => DECISION)
  end

  def fake_cli(dir)
    path = File.join(dir, "fake-cli")
    File.write(path, fake_cli_source)
    File.chmod(0o755, path)
    path
  end

  def fake_cli_source
    <<~RUBY
      #!/usr/bin/env ruby
      require "json"
      File.write(ENV.fetch("FAKE_ARGV"), JSON.generate(ARGV))
      File.write(ENV.fetch("FAKE_STDIN"), $stdin.read)
      print ENV.fetch("FAKE_STDOUT")
    RUBY
  end

  def write_file(dir, name, contents)
    path = File.join(dir, name)
    File.write(path, contents, encoding: "UTF-8")
    path
  end
end

class HeadlessRoutingAdapterSystemTest < Minitest::Test
  include HeadlessAdapterFixture

  def test_each_routing_adapter_requires_a_model
    HeadlessAdapterFixture::ADAPTERS.each_key do |provider|
      capture_without_model(provider)
    end
  end

  def test_each_routing_adapter_writes_the_normalized_result
    HeadlessAdapterFixture::ADAPTERS.each_key do |provider|
      capture(provider, :routing) do |dir, _out, err, status|
        result = JSON.parse(File.read(File.join(dir, "result.json"), encoding: "UTF-8"))

        assert_predicate status, :success?, err
        assert_equal provider.to_s, result.dig("metadata", "provider")
        assert_equal DECISION["primary_skill"], result.fetch("primary_skill")
      end
    end
  end

  def test_cursor_routing_rejects_an_unknown_skill
    decision = DECISION.merge("primary_skill" => "not-a-skill")
    capture(:cursor, :routing, stdout: cursor_stdout(decision)) do |_dir, _out, err, status|
      refute_predicate status, :success?
      assert_includes err, "primary_skill must be registered"
    end
  end

  def test_cursor_routing_stays_in_ask_mode
    capture(:cursor, :routing) do |dir, _out, err, status|
      argv, stdin = recorded(dir)

      assert_predicate status, :success?, err
      assert_includes argv, "ask"
      assert_includes stdin, "Task:"
    end
  end

  def test_antigravity_routing_disables_skill_expansion
    capture(:antigravity, :routing) do |dir, _out, _err, status|
      argv, = recorded(dir)

      assert_predicate status, :success?
      assert_includes argv, "--disable-slash-commands"
      refute_includes argv, "--dangerously-skip-permissions"
    end
  end

  def test_opencode_routing_does_not_auto_approve_tools
    capture(:opencode, :routing) do |dir, _out, _err, status|
      argv, = recorded(dir)

      assert_predicate status, :success?
      assert_includes argv, "--standalone"
      refute_includes argv, "--auto"
    end
  end

  private

  def capture_without_model(provider)
    Dir.mktmpdir do |dir|
      _out, err, status = run_adapter(dir, provider, :routing, model: nil)

      refute_predicate status, :success?
      assert_includes err, "must be set"
      refute File.file?(File.join(dir, "argv.json"))
    end
  end
end

class HeadlessCodingAdapterSystemTest < Minitest::Test
  include HeadlessAdapterFixture

  def test_cursor_coding_forces_edits_in_the_workspace
    capture(:cursor, :coding) do |dir, _out, err, status|
      argv, stdin = recorded(dir)

      assert_predicate status, :success?, err
      assert_includes argv, "--force"
      assert_equal "implement the task", stdin
    end
  end

  def test_antigravity_coding_accepts_edits_without_skill_expansion
    capture(:antigravity, :coding) do |dir, _out, _err, status|
      argv, = recorded(dir)

      assert_predicate status, :success?
      assert_includes argv, "accept-edits"
      assert_includes argv, "--disable-slash-commands"
    end
  end

  def test_opencode_coding_auto_approves_inside_a_private_server
    capture(:opencode, :coding) do |dir, _out, _err, status|
      argv, = recorded(dir)

      assert_predicate status, :success?
      assert_includes argv, "--auto"
      assert_includes argv, "--standalone"
    end
  end
end
