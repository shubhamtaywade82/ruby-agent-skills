# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsOperationalTasksMaintenanceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-operational-tasks-maintenance/SKILL.md
    patterns/rails/operational-task-boundary.md
    patterns/rails/task-namespace-contract.md
    patterns/rails/environment-gate-contract.md
    patterns/rails/operational-dry-run-contract.md
    patterns/rails/idempotent-maintenance-contract.md
    patterns/rails/batch-checkpoint-contract.md
    patterns/rails/maintenance-lock-contract.md
    patterns/rails/mutation-invariant-contract.md
    patterns/rails/partial-failure-contract.md
    patterns/rails/operational-observability-contract.md
    patterns/rails/scheduled-maintenance-overlap-contract.md
    patterns/rails/data-repair-verification-contract.md
    patterns/rails/production-runbook-command-contract.md
    evals/rails/operational-tasks-maintenance-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT, p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-operational-tasks-maintenance")
    assert_equal "skills/rails-operational-tasks-maintenance/SKILL.md",s.fetch("path")
    %w[Rake task lib/tasks bin/rails runner maintenance cleanup backfill repair reconciliation dry-run idempotent checkpoint lock runbook].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("evaluations").fetch("rails-operational-tasks-maintenance").fetch("paths"), "evals/rails/operational-tasks-maintenance-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Operational Tasks and Maintenance engineering"
    assert_includes routing,"rails-operational-tasks-maintenance"
    assert_includes agents,"Rails operational task/maintenance changes"
    assert_includes agents,"environment gates"
    assert_includes validator,"rails_operational_tasks_maintenance_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/operational-tasks-maintenance-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-operational-tasks-maintenance"
    assert_includes e.fetch("patterns"),"idempotent-maintenance-contract"
    assert_includes e.fetch("patterns"),"production-runbook-command-contract"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-operational-tasks-maintenance/SKILL.md"),encoding:"UTF-8")
    [
      "Task ownership and naming","Preconditions and environment gates","Idempotency and resumability",
      "Transactions and batch boundaries","Concurrency and locking","Mutation safety",
      "Dry run and operator feedback","Failure handling and recovery","Scheduling and recurring operations",
      "Data repair and backfills","Testing strategy"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Prefer a task or runner workflow that can be inspected, tested, and rerun safely"
  end
end
