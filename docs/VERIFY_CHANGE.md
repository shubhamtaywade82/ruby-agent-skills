# Change verification

`bin/verify-change` verifies a change in **your** Ruby/Rails project and writes an evidence report. It is the consumer-side counterpart to `bin/validate`, which validates this skill pack itself.

It is provider-neutral: it does not call a model, load skills, or depend on any agent. Any agent, script, or CI job that can run a shell command can run it. It needs only Ruby and git (tested on Ruby 3.3, the version CI uses); it uses the standard library and runs the tools your project already has.

## Why it exists

The skills and `AGENTS.md` instruct an agent to test, lint, and check security before calling a change done. An instruction is not enforcement. `bin/verify-change` turns "verify the change" into one command with a machine-readable result and an exit code, so a claim of "done" can be checked instead of trusted.

It never reports a check as passed when it did not run. A check that applies but could not run is `skipped`, and the overall status is then `incomplete`, not `pass`.

## Usage

    ruby bin/verify-change [PATH] [options]

`PATH` defaults to the current directory. From an installed pack (`bin/install`), the same tool is at `<agent-skill-root>/.ruby-agent-skills/bin/verify-change`.

| Option | Meaning |
| --- | --- |
| `--base REF` | Also include commits since `REF` (`git diff REF...HEAD`). Without it, the change is the working tree versus `HEAD`, including untracked files. |
| `--files a,b` | Use this list instead of git detection. Repeatable. |
| `--only LIST` / `--skip LIST` | Run or skip checks by id. Unknown ids are a usage error. |
| `--test-command CMD` | Override test detection. Split on whitespace and run **without a shell**. |
| `--timeout SECONDS` | Per-check limit (default 900). The whole process group is killed on expiry and the check fails. |
| `--format json\|markdown` | Stdout format. Markdown is suitable for a pull-request comment or `$GITHUB_STEP_SUMMARY`. |
| `--out FILE` | Also write the JSON evidence report to `FILE`. |
| `--strict` | Exit 3 when an applicable check could not run. |
| `--no-output` | Omit command output tails from the report. |
| `--list-checks` | Print check ids. |

### Exit codes

| Code | Meaning |
| --- | --- |
| 0 | `pass`, or `incomplete` without `--strict` (read `overall.status`) |
| 1 | a check failed |
| 2 | usage error |
| 3 | `incomplete` under `--strict` |

Use `--strict` in CI so an unrunnable check cannot pass silently.

## Checks

| Id | Applies when | What it does |
| --- | --- | --- |
| `runtime_profile` | always | Resolves Ruby/Rails/Bundler/CI versions with `RuntimeProfile`; `warn` if the evidence conflicts. |
| `dependency_lock_sync` | `Gemfile` changed and `Gemfile.lock` is tracked | Fails if the lockfile did not change with the Gemfile. |
| `migration_integrity` | files under `db/migrate/` changed | Fails if a tracked `db/schema.rb`/`db/structure.sql` did not change with the migration; `warn` when an existing migration was edited. |
| `test_presence` | `app/` or `lib/` Ruby changed | `warn` when no test or spec file changed. Advisory only. |
| `rubocop` | Ruby files changed and `.rubocop.yml` exists | Runs RuboCop on the changed files only, with `--force-exclusion`. |
| `tests` | Ruby or dependency files changed | Runs `bundle exec rspec` (spec/ and rspec-core in the lockfile), `bin/rails test` (Rails app with test/), or `--test-command`. Runs the whole suite: selecting tests from a diff is a heuristic this tool does not make. |
| `brakeman` | Rails app and Ruby/dependency change | Runs Brakeman (`--format json`), and reports warning and error counts. |
| `bundler_audit` | `Gemfile.lock` exists and a dependency file changed | Runs `bundler-audit check`. |
| `zeitwerk` | Rails app and `app/`, `lib/`, or `config/` Ruby changed | Runs `rails zeitwerk:check`. |

Tools are resolved from the project's bundle when the gem is in `Gemfile.lock`, otherwise from `PATH`. A missing tool (including `bundle exec` exit 127, or a gem the bundle cannot find) is `skipped`, not `fail`.

### Statuses

| Status | Meaning | Effect on overall |
| --- | --- | --- |
| `pass` | ran and succeeded | none |
| `fail` | ran and failed, timed out, or the verifier errored | overall `fail` |
| `warn` | advisory finding | none |
| `skipped` | applicable but could not run | overall `incomplete` |
| `not_applicable` | nothing in the change requires it | none |

## Report

`schema_version` 1. Top-level keys:

- `generated_at`, `repository`
- `git`: `head`, `branch`, `base`, `dirty`
- `change`: `source`, `modified`, `added`, `deleted`, `categories` (including `frontend_unverified`: JS/TS/CSS files this tool does not verify; use the frontend pack for them)
- `contract_pointers`: owning skills whose `## <Domain> changes` contract applies to the changed paths. This is a routing hint; the tool does **not** verify contract adherence
- `checks`: per check, `status`, `reason`, `command`, `exit_code`, `duration_seconds`, `summary`, `output_tail` (last 4 KB)
- `summary`: counts per status
- `overall`: `status`, `strict`, `exit_code`

Output tails are captured verbatim from your tools. If your test output can contain secrets, use `--no-output`, and treat the report as you would CI logs.

## What it does not do

- It does not judge design quality, contract adherence, or whether tests are meaningful. It runs your project's own gates and a few deterministic structural checks.
- It does not validate frontend code.
- It does not replace human review or `change-review`; it gives the reviewer evidence.
- It does not make an agent use it. Nothing here can force an agent to run a command; the enforcement point that works is CI running it with `--strict`.

## Wiring it in

### Any agent

Add one line to your agent instructions (`AGENTS.md`, `CLAUDE.md`, Cursor rules, Copilot instructions):

    Before reporting a change done, run `ruby <path>/verify-change --base origin/main --strict`
    and report `overall.status` and any check that is not `pass`.

### CI (the enforcement point)

```yaml
- uses: actions/checkout@v7
  with:
    fetch-depth: 0
- uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true
- name: Get the skill pack
  run: git clone --depth 1 --branch <tag> https://github.com/shubhamtaywade82/ruby-agent-skills "$RUNNER_TEMP/ras"
- name: Verify change
  run: |
    ruby "$RUNNER_TEMP/ras/bin/verify-change" --base "origin/${{ github.base_ref }}" \
      --strict --out verify-change.json --format markdown >> "$GITHUB_STEP_SUMMARY"
- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: verify-change
    path: verify-change.json
```

Pin `<tag>` to a release tag or commit, as for `bin/install`.

## Design notes

- Commands are run as argv arrays with no shell, so file names and `--test-command` values are never interpreted by a shell. Changed file paths are passed to RuboCop after `--`.
- The runner strips `BUNDLE_GEMFILE`, `BUNDLE_BIN_PATH`, `BUNDLER_SETUP`, `BUNDLER_VERSION`, and `RUBYLIB` so running the verifier under another bundle cannot redirect the project's tools.
- Deliberate ceiling: the `tests` check always runs the full suite. Revisit if a project's suite is too slow to run per change; use `--test-command` to narrow it in the meantime.
