#!/usr/bin/env bash
set -euo pipefail
# Usage: run_focused_tests.sh path/to/test_or_spec [additional test paths...]
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <test/spec path> [additional paths...]" >&2
  exit 2
fi
for path in "$@"; do
  if [[ ! -f "$path" ]]; then
    echo "Test path does not exist: $path" >&2
    exit 2
  fi
done
if [[ ! -f Gemfile ]]; then
  echo "No Gemfile found; refusing to guess a test runner." >&2
  exit 2
fi
if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler is unavailable." >&2
  exit 2
fi
if [[ -f .rspec ]] || grep -qE '(^|[[:space:]])rspec([[:space:]]|$)' Gemfile Gemfile.lock 2>/dev/null; then
  exec bundle exec rspec "$@"
fi
if [[ -f bin/rails ]]; then
  exec bundle exec rails test "$@"
fi
echo "Could not identify the repository's test runner; follow the project's documentation." >&2
exit 2
