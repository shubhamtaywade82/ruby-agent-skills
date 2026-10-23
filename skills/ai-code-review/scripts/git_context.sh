#!/usr/bin/env bash
set -euo pipefail
# Read-only context helper. Usage: git_context.sh <file> [base-ref]
target="${1:?Usage: git_context.sh <file> [base-ref]}"
base="${2:-main}"
git rev-parse --show-toplevel
printf '\n== Target ==\n%s\n' "$target"
printf '\n== Recent history ==\n'
git log -8 --oneline -- "$target"
printf '\n== Base comparison ==\n'
if git rev-parse --verify "$base" >/dev/null 2>&1; then
  git diff --stat "$base"...HEAD -- "$target" || true
else
  printf 'Base ref %s not found; skipped comparison.\n' "$base"
fi
printf '\n== Candidate references ==\n'
name="$(basename "$target" | sed 's/\.[^.]*$//')"
git grep -n -F "$name" -- ':!vendor' ':!tmp' 2>/dev/null | head -100 || true
printf '\n== Candidate tests ==\n'
find . -type f \( -path '*/test/*' -o -path '*/spec/*' \) -print 2>/dev/null | grep -F "$name" | head -50 || true
